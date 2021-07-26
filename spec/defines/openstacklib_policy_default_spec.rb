require 'spec_helper'

describe 'openstacklib::policy::default' do
  shared_examples 'openstacklib::policy::default' do
    context 'with policy.json' do
      let :title do
        '/etc/nova/policy.json'
      end

      let :params do
        {
          :file_mode   => '0644',
          :file_user   => 'foo',
          :file_group  => 'bar',
          :file_format => 'json',
        }
      end

      it { should contain_file('/etc/nova/policy.json').with(
        :mode    => '0644',
        :owner   => 'foo',
        :group   => 'bar',
        :content => '{}',
        :replace => false
      )}
    end

    context 'with policy.yaml' do
      let :title do
        '/etc/nova/policy.yaml'
      end

      let :params do
        {
          :file_mode   => '0644',
          :file_user   => 'foo',
          :file_group  => 'bar',
          :file_format => 'yaml',
        }
      end

      it { should contain_file('/etc/nova/policy.yaml').with(
        :mode    => '0644',
        :owner   => 'foo',
        :group   => 'bar',
        :content => '',
        :replace => false
      )}
    end

    context 'with purge_config enabled' do
      let :title do
        '/etc/nova/policy.yaml'
      end

      let :params do
        {
          :file_mode    => '0644',
          :file_user    => 'foo',
          :file_group   => 'bar',
          :file_format  => 'yaml',
          :purge_config => true,
        }
      end

      it { should contain_file('/etc/nova/policy.yaml').with(
        :mode    => '0644',
        :owner   => 'foo',
        :group   => 'bar',
        :content => '',
        :replace => true
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

      it_behaves_like 'openstacklib::policy::default'
    end
  end
end
