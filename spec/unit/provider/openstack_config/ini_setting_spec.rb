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
      :name              => 'DEFAUL/foo',
      :value             => 'bar',
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

  let(:resource) do
    resource = type.new(properties)
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

end
