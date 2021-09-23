require 'spec_helper'

describe 'openstacklib::openstackclient' do
  shared_examples_for 'openstacklib::openstackclient' do
    context 'with default params' do
      it { should contain_package(platform_params[:openstackclient_package_name]).with(
        :ensure => 'installed',
        :tag    => 'openstack'
      )}
    end

    context 'with non default package name' do
      let :params do
        {
          :package_name => 'my-openstackclient'
        }
      end

      it { should contain_package('my-openstackclient').with(
        :ensure => 'installed',
        :tag    => 'openstack'
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :openstackclient_package_name => 'python3-openstackclient' }
        when 'RedHat'
          { :openstackclient_package_name => 'python3-openstackclient' }
        end
      end

      it_behaves_like 'openstacklib::openstackclient'
    end
  end

end
