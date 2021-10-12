require 'facter'

Puppet::Type.type(:openstack_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def exists?
    immutable_string = Facter.value(:os_immutable) || '<_IMMUTABLE_>'
    if resource[:value] == ensure_absent_val
      resource[:ensure] = :absent
    elsif resource[:value] == immutable_string or resource[:value] == [immutable_string]
      resource[:value] = value
      # when the value is undefined, we keep it that way.
      if value.nil? or (value.kind_of?(Array) and value[0].nil?)
        resource[:ensure] = :absent
      end
    end
    super
  end

  def create
    resource[:value] = transform(:to, resource[:value])
    super
  end

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def value=(value)
    new_value = transform(:to, value)

    ini_file.set_value(section, setting, new_value)
    ini_file.save
  end

  def value
    value = ini_file.get_value(section, setting)
    new_value = transform(:from, value)
    @property_hash[:value] = new_value
    new_value
  end

  def ensure_absent_val
    resource[:ensure_absent_val]
  end

  def transform_to
    return nil unless resource.to_hash.has_key? :transform_to
    resource[:transform_to]
  end

  def transform_to=(value)
    @property_hash[:transform_to] = value
  end

  def separator
    if resource.class.validattr?(:key_val_separator)
      resource[:key_val_separator] || '='
    else
      '='
    end
  end

  def file_path
    self.class.file_path
  end

  def transform(direction, value)
    new_value = value
    if !transform_to.nil? && !transform_to.empty?
      transformation_function = "#{direction}_#{transform_to}".to_sym
      if self.respond_to?(transformation_function)
        new_value = send(transformation_function, value)
      else
        error("Cannot find transformation #{transformation_function} for #{value}")
      end
    end
    new_value
  end
end
