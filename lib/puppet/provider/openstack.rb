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

  # this actions are not idempotent and retries can cause
  # duplications or endless loops
  def self.no_retry_actions
    %w(create remove delete)
  end

  # timeout the openstack command
  # after this number of seconds
  # retry the command until the request_timeout
  def self.command_timeout
    20
  end

  # timeout the entire request with error
  # after this number of seconds
  def self.request_timeout
    60
  end

  # sleep for this number of seconds
  # between command retries
  def self.retry_sleep
    3
  end

  # run the openstack command
  # with command_timeout
  def self.openstack(*args)
    begin
      Timeout.timeout(command_timeout) do
        openstack_command *args
      end
    rescue Timeout::Error
      raise Puppet::ExecutionFailure, "Command: 'openstack #{args.inspect}' has been running for more then #{command_timeout} seconds!"
    end
  end

  # get the current timestamp
  def self.current_time
    Time.now.to_i
  end

  # Returns an array of hashes, where the keys are the downcased CSV headers
  # with underscores instead of spaces
  def self.request(service, action, properties, credentials=nil)
    env = credentials ? credentials.to_env : {}
    Puppet::Util.withenv(env) do
      rv = nil
      end_time = current_time + request_timeout
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
          raise exception if current_time > end_time
          debug "Non-fatal error: '#{exception.message}'. Retrying for #{end_time - current_time} more seconds"
          raise exception if no_retry_actions.include? action
          sleep retry_sleep
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
