
require File.expand_path('../../../util/openstackconfig', __FILE__)


Puppet::Type.type(:openstack_config).provide(:ruby) do

  def self.instances
    if self.respond_to?(:file_path)
      config = Puppet::Util::OpenStackConfig.new(file_path)
      resources = []
      config.section_names.each do |section_name|
        config.get_settings(section_name).each do |setting, value|
          resources.push(
            new(
              :name   => namevar(section_name, setting),
              :value  => value,
              :ensure => :present
            )
          )
        end
      end
      resources
    else
      raise(Puppet::Error,
        'OpenStackConfig only support collecting instances when a file path ' +
        'is hard coded'
      )
    end
  end

  def self.namevar(section_name, setting)
    "#{section_name}/#{setting}"
  end

  def exists?
    if resource[:value] == ensure_absent_val
      resource[:ensure] = :absent
    end
    !config.get_value(section, setting).nil?
  end

  def create
    config.set_value(section, setting, resource[:value])
    config.save
    @config = nil
  end

  def destroy
    config.remove_setting(section, setting)
    config.save
    @config = nil
  end

  def value=(value)
    config.set_value(section, setting, resource[:value])
    config.save
  end

  def value
    val = config.get_value(section, setting)
    if !val.kind_of?(Array)
      [val]
    else
      val
    end
  end

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def ensure_absent_val
    # :array_matching => :all values comes in form of array even when they
    # are passed as single string
    if resource[:value].kind_of?(Array) and not resource[:ensure_absent_val].kind_of?(Array)
      [resource[:ensure_absent_val]]
    else
      resource[:ensure_absent_val]
    end
  end

  def file_path
    self.class.file_path
  end

  private
  def config
    @config ||= Puppet::Util::OpenStackConfig.new(file_path)
  end
end
