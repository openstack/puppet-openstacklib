#
# these tests are a little concerning b/c they are hacking around the
# modulepath, so these tests will not catch issues that may eventually arise
# related to loading these plugins.
# I could not, for the life of me, figure out how to programatcally set the modulepath
$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    '..',
    'fixtures',
    'modules',
    'inifile',
    'lib')
)
require 'spec_helper'
provider_class = Puppet::Type.type(:openstack_config).provider(:ini_setting)
describe provider_class do

  let(:properties) do
    {
      :name              => 'DEFAULT/foo',
      :value             => 'bar',
      :ensure_absent_val => 'some_value',
      :ensure            => :present,
    }
  end

  let(:transform_properties) do
    {
      :name              => 'DEFAULT/foo',
      :value             => 'bar',
      :transform_to      => 'upper',
      :ensure_absent_val => 'some_value',
      :ensure            => :present,
    }
  end

  let(:type) do
    Puppet::Type.newtype(:test_config) do
      newparam(:name, :namevar => true)
      newparam(:ensure)
      newproperty(:value)
      newparam(:ensure_absent_val)
    end
  end

  let(:transform_type) do
    Puppet::Type.newtype(:test_config) do
      newparam(:name, :namevar => true)
      newparam(:ensure)
      newproperty(:value)
      newparam(:ensure_absent_val)
      newparam(:transform_to)
    end
  end

  let(:resource) do
    resource = type.new(properties)
    resource
  end

  let(:transform_resource) do
    resource = transform_type.new(transform_properties)
    resource
  end

  context '#exists?' do
    it 'ensure to present' do
      child_conf = Class.new(provider_class) do
          def self.file_path
            '/some/file/path'
          end
      end
      provider = child_conf.new(resource)
      provider.exists?
      expect(resource[:ensure]).to eq :present
    end

    it 'ensure to absent' do
      child_conf = Class.new(provider_class) do
          def self.file_path
            '/some/file/path'
          end
      end
      provider = child_conf.new(resource)
      resource[:ensure_absent_val] = 'bar'
      provider.exists?
      expect(resource[:ensure]).to eq :absent
    end
  end

  context 'transform_to' do
    it 'transforms a property' do
      child_conf = Class.new(provider_class) do
          def self.file_path
            '/some/file/path'
          end

          def to_upper(value)
            value.upcase!
          end
      end
      provider = child_conf.new(transform_resource)
      provider.exists?
      provider.transform(:to, transform_resource[:value])
      expect(transform_resource[:value]).to eq 'BAR'
    end

  end

end
