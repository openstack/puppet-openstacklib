require 'csv'
require 'puppet'
require 'timeout'

class Puppet::Error::OpenstackAuthInputError < Puppet::Error
end

class Puppet::Error::OpenstackUnauthorizedError < Puppet::Error
end

class Puppet::Provider::Openstack < Puppet::Provider

  initvars # so commands will work
  commands :openstack_command => 'openstack'

  @@no_retry_actions = %w(create remove delete)
  @@command_timeout  = 40
  # Fails on the 5th retry for a max of 212s (~3.5min) before total
  # failure.
  @@request_timeout  = 170
  @@retry_sleep      = 3
  class << self
    [:no_retry_actions, :request_timeout, :retry_sleep].each do |m|
      define_method m do
        self.class_variable_get("@@#{m}")
      end
      define_method :"#{m}=" do |value|
        self.class_variable_set("@@#{m}", value)
      end
    end
  end

  # timeout the openstack command
  # after this number of seconds
  # retry the command until the request_timeout,
  # unless it's a no_retry_actions call
  def self.command_timeout(action=nil)
    # give no_retry actions the full time limit to finish
    return self.request_timeout() if no_retry_actions.include? action
    self.class_variable_get("@@command_timeout")
  end

  # with command_timeout
  def self.openstack(*args)
    begin
      action = args[1]
      Timeout.timeout(command_timeout(action)) do
        openstack_command *args
      end
    rescue Timeout::Error
      raise Puppet::ExecutionFailure, "Command: 'openstack #{args.inspect}' has been running for more than #{command_timeout(action)} seconds"
    end
  end

  # get the current timestamp
  def self.current_time
    Time.now.to_i
  end

  def self.request_without_retry(&block)
    previous_timeout = self.request_timeout
    rc = nil
    if block_given?
      self.request_timeout = 0
      rc = yield
    end
  ensure
    self.request_timeout = previous_timeout
    rc
  end

  # Returns an array of hashes, where the keys are the downcased CSV headers
  # with underscores instead of spaces
  #
  # @param options [Hash] Other options
  # @options :no_retry_exception_msgs [Array<Regexp>,Regexp] exception without retries
  def self.request(service, action, properties, credentials=nil, options={})
    env = credentials ? credentials.to_env : {}
    no_retry = options[:no_retry_exception_msgs]

    Puppet::Util.withenv(env) do
      rv = nil
      end_time = current_time + request_timeout
      start_time = current_time
      retry_count = 0
      loop do
        begin
          if action == 'list'
            # shell output is:
            # ID,Name,Description,Enabled
            response = openstack(service, action, '--quiet', '--format', 'csv', properties)
            response = parse_csv(response)
            keys = response.delete_at(0)
            rv = response.collect do |line|
              hash = {}
              keys.each_index do |index|
                key = keys[index].downcase.gsub(/ /, '_').to_sym
                hash[key] = line[index]
              end
              hash
            end
          elsif action == 'show' or action == 'create'
            rv = {}
            # shell output is:
            # name="value1"
            # id="value2"
            # description="value3"
            openstack(service, action, '--format', 'shell', properties).split("\n").each do |line|
              # key is everything before the first "="
              key, val = line.split('=', 2)
              next unless val # Ignore warnings
              # value is everything after the first "=", with leading and trailing double quotes stripped
              val = val.gsub(/\A"|"\Z/, '')
              rv[key.downcase.to_sym] = val
            end
          else
            rv = openstack(service, action, properties)
          end
          break
        rescue Puppet::ExecutionFailure => exception
          raise Puppet::Error::OpenstackUnauthorizedError, 'Could not authenticate' if exception.message =~ /HTTP 40[13]/
          if current_time > end_time
            error_message = exception.message
            error_message += " (tried #{retry_count}, for a total of #{end_time - start_time } seconds)"
            raise(Puppet::ExecutionFailure, error_message)
          end

          raise exception if no_retry_actions.include? action
          if no_retry
            no_retry = [no_retry] unless no_retry.is_a?(Array)
            no_retry.each do |nr|
              raise exception if exception.message.match(nr)
            end
          end
          debug "Non-fatal error: '#{exception.message}'. Retrying for #{end_time - current_time} more seconds"
          sleep retry_sleep
          retry_count += 1
          retry
        end
      end
      return rv
    end
  end

  private

  def self.parse_csv(text)
    # Ignore warnings - assume legitimate output starts with a double quoted
    # string.  Errors will be caught and raised prior to this
    text = text.split("\n").drop_while { |line| line !~ /^\".*\"/ }.join("\n")
    return CSV.parse(text + "\n")
  end
end
