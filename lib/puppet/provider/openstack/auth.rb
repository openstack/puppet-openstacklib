#require 'puppet/provider/openstack/credentials'
require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/openstack/credentials')

module Puppet::Provider::Openstack::Auth

  RCFILENAME = "#{ENV['HOME']}/openrc"

  CLOUDSFILENAMES = [
    # This allows overrides by users
    "/etc/openstack/puppet/clouds.yaml",
    # This is created by puppet-keystone
    "/etc/openstack/puppet/admin-clouds.yaml",
    ]

  def get_os_vars_from_env
    env = {}
    ENV.each { |k,v| env.merge!(k => v) if k =~ /^OS_/ }
    return env
  end

  def get_os_vars_from_cloudsfile(scope)
    cloudsfile = clouds_filenames.detect { |f| File.exists? f}
    unless cloudsfile.nil?
      {
        'OS_CLOUD'              => scope,
        'OS_CLIENT_CONFIG_FILE' => cloudsfile
      }
    else
      {}
    end
  end

  def get_os_vars_from_rcfile(filename)
    env = {}
    rcfile = [filename, '/root/openrc'].detect { |f| File.exists? f }
    unless rcfile.nil?
      File.open(rcfile).readlines.delete_if{|l| l=~ /^#|^$/ }.each do |line|
        # we only care about the OS_ vars from the file LP#1699950
        if line =~ /OS_/
          key, value = line.split('=')
          key = key.split(' ').last
          value = value.chomp.gsub(/'/, '')
          env.merge!(key => value) if key =~ /OS_/
        end
      end
    end
    return env
  end

  def rc_filename
    RCFILENAME
  end

  def clouds_filenames
    CLOUDSFILENAMES
  end

  def request(service, action, properties=nil, options={}, scope='project')
    properties ||= []

    # First, check environments
    set_credentials(@credentials, get_os_vars_from_env)

    unless @credentials.set? and (!@credentials.scope_set? or @credentials.scope == scope)
      # Then look for clouds.yaml
      @credentials.unset
      clouds_env = get_os_vars_from_cloudsfile(scope)
      if ! clouds_env.empty?
        set_credentials(@credentials, clouds_env)
      else
        # If it fails then check rc files, to keep backword compatibility.
        warning('Usage of rc file is deprecated and will be removed in a future release.')
        @credentials.unset
        set_credentials(@credentials, get_os_vars_from_rcfile(rc_filename))
      end
    end

    unless @credentials.set? and (!@credentials.scope_set? or @credentials.scope == scope)
      raise(Puppet::Error::OpenstackAuthInputError, 'Insufficient credentials to authenticate')
    end
    super(service, action, properties, @credentials, options)
  end

  def set_credentials(creds, env)
    env.each do |key, val|
      var = key.sub(/^OS_/,'').downcase
      creds.set(var, val)
    end
  end
end
