require 'spec_helper'

describe 'openstacklib::clouds' do
  shared_examples 'openstacklib::clouds' do
    let :title do
      '/etc/openstack/clouds.yaml'
    end

    context 'with the required parameters' do
      let :params do
        {
          :username     => 'admin',
          :password     => 'secrete',
          :auth_url     => 'http://127.0.0.1:5000/',
          :project_name => 'demo',
        }
      end

      it 'creates a clouds.yaml file' do
        should contain_file('/etc/openstack/clouds.yaml').with(
          :mode  => '0600',
          :owner => 'root',
          :group => 'root',
        )
      end
    end

    context 'with file owner/group' do
      let :params do
        {
          :username     => 'admin',
          :password     => 'secrete',
          :auth_url     => 'http://127.0.0.1:5000/',
          :project_name => 'demo',
          :file_user    => 'foo',
          :file_group   => 'bar',
        }
      end

      it 'creates a clouds.yaml file with correct ownership' do
        should contain_file('/etc/openstack/clouds.yaml').with(
          :mode  => '0600',
          :owner => 'foo',
          :group => 'bar',
        )
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'openstacklib::clouds'
    end
  end

end
