Puppet::Type.type(:openstack_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def exists?
    if resource[:value] == ensure_absent_val
      resource[:ensure] = :absent
    end
    super
  end

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def ensure_absent_val
    resource[:ensure_absent_val]
  end

  def separator
    '='
  end

  def file_path
    self.class.file_path
  end

end
