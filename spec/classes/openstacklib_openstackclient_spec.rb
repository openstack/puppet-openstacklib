require 'spec_helper'

describe 'openstacklib::openstackclient' do

  shared_examples_for 'openstacklib::openstackclient' do
    context 'with default params' do
      it 'installs openstackclient' do
        is_expected.to contain_package(platform_params[:openstackclient_package_name]).with(
          :ensure => 'present',
          :tag    => 'openstack'
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        if facts[:os_package_type] == 'debian' then
          openstackclient_package_name = 'python3-openstackclient'
        else
          openstackclient_package_name = 'python-openstackclient'
        end
        {
          :openstackclient_package_name => openstackclient_package_name
        }
      end

      it_behaves_like 'openstacklib::openstackclient'
    end
  end

end
