require 'spec_helper'

describe 'openstacklib::iscsid' do
  shared_examples_for 'openstacklib::iscsid' do
    context 'with default params' do
      it { is_expected.to contain_package('open-iscsi').with(
        :name   => platform_params[:open_iscsi_package_name],
        :ensure => 'present',
        :tag    => 'openstack',
      )}

      it { is_expected.to contain_exec('create-initiatorname-file').with({
        :command => 'echo "InitiatorName=`/usr/sbin/iscsi-iname`" > /etc/iscsi/initiatorname.iscsi',
        :path    => ['/usr/bin','/usr/sbin','/bin','/usr/bin'],
        :creates => '/etc/iscsi/initiatorname.iscsi',
      }).that_requires('Package[open-iscsi]')}

      it { is_expected.to contain_service('iscsid').with(
        :ensure => 'running',
        :enable => true,
      ) }
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
        case facts[:os]['family']
        when 'Debian'
          { :open_iscsi_package_name => 'open-iscsi' }
        when 'RedHat'
          { :open_iscsi_package_name => 'iscsi-initiator-utils' }
        end
      end

      it_behaves_like 'openstacklib::iscsid'
    end
  end

end
