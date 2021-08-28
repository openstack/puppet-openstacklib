require 'puppet'
require 'puppet/provider/openstack'

class Puppet::Provider::Openstack::Credentials

  KEYS = [
    :auth_url, :password, :project_name, :username,
    :token, :endpoint, :url,
    :identity_api_version,
    :region_name,
    :interface
  ]

  KEYS.each { |var| attr_accessor var }

  def self.defined?(name)
    KEYS.include?(name.to_sym)
  end

  def set(key, val)
    if self.class.defined?(key.to_sym)
      self.instance_variable_set("@#{key}".to_sym, val)
    end
  end

  def set?
    return true if user_password_set? || service_token_set?
  end

  def service_token_set?
    return true if (@token && @endpoint) || (@token && @url)
  end

  def to_env
    env = {}
    self.instance_variables.each do |var|
      name = var.to_s.sub(/^@/,'OS_').upcase
      env.merge!(name => self.instance_variable_get(var))
    end
    env
  end

  def scope_set?
    @project_name
  end

  def scope
    if @project_name
      return 'project'
    else
      # When only service token is used, there is not way to determine
      # the scope unless we inspect the token using keystone API call.
      return nil
    end
  end

  def user_password_set?
    return true if @username && @password && @project_name && @auth_url
  end

  def unset
    self.instance_variables.each do |var|
      if var.to_s != '@identity_api_version' &&
        self.instance_variable_defined?(var.to_s)
        set(var.to_s.sub(/^@/,''), '')
      end
    end
  end

  def version
    self.class.to_s.sub(/.*V/,'').sub('_','.')
  end
end

class Puppet::Provider::Openstack::CredentialsV3 < Puppet::Provider::Openstack::Credentials

  KEYS = [
    :cacert,
    :cert,
    :default_domain,
    :domain_id,
    :domain_name,
    :key,
    :project_domain_id,
    :project_domain_name,
    :project_id,
    :system_scope,
    :trust_id,
    :user_domain_id,
    :user_domain_name,
    :user_id
  ]

  KEYS.each { |var| attr_accessor var }

  def self.defined?(name)
    KEYS.include?(name.to_sym) || super
  end

  def user_set?
    @username || @user_id
  end

  def scope_set?
    @system_scope || @domain_name || @domain_id || @project_name || @project_id
  end

  def scope
    if @project_name || @project_id
      return 'project'
    elsif @domain_name || @domain_id
      return 'domain'
    elsif @system_scope
      return 'system'
    else
      return nil
    end
  end

  def user_password_set?
    return true if user_set? && @password && scope_set? && @auth_url
  end

  def initialize
    set(:identity_api_version, version)
  end
end
