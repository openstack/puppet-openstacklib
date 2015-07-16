$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet_x/openstack/util/ini_file'

Puppet::Type.type(:openstack_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def file_path
    self.class.file_path
  end

  private
  def ini_file
    @ini_file ||= PuppetX::Openstack::Util::IniFile.new(file_path, separator, section_prefix, section_suffix)
  end

end
