require 'spec_helper'

describe 'openstacklib::policy' do
  shared_examples 'openstacklib::policy' do
    context 'with basic configuration' do
      let :title do
        '/etc/nova/policy.json'
      end

      let :params do
        {
          :policies => {
            'foo' => {
              'key'       => 'context_is_admin',
              'value'     => 'foo:bar'
            }
          },
          :file_mode    => '0644',
          :file_user    => 'foo',
          :file_group   => 'baa',
          :file_format  => 'json',
        }
      end

      it { should contain_openstacklib__policy__base('foo').with(
        :file_path => '/etc/nova/policy.json',
        :key       => 'context_is_admin',
        :value     => 'foo:bar'
      )}
    end

    context 'with yaml configuration' do
      let :title do
        '/etc/nova/policy.yaml'
      end

      let :params do
        {
          :policies     => {
            'foo' => {
              'key'       => 'context_is_admin',
              'value'     => 'foo:bar'
            }
          },
          :file_mode    => '0644',
          :file_user    => 'foo',
          :file_group   => 'baa',
          :file_format  => 'yaml',
        }
      end

      it { should contain_openstacklib__policy__base('foo').with(
        :file_path => '/etc/nova/policy.yaml',
        :key       => 'context_is_admin',
        :value     => 'foo:bar'
      )}
    end

    context 'with empty policies and purge_config enabled' do
      let :title do
        '/etc/nova/policy.yaml'
      end

      let :params do
        {
          :file_mode    => '0644',
          :file_user    => 'foo',
          :file_group   => 'baa',
          :file_format  => 'yaml',
          :purge_config => true,
        }
      end

      it { should contain_openstacklib__policy__default('/etc/nova/policy.yaml').with(
        :file_mode    => '0644',
        :file_user    => 'foo',
        :file_group   => 'baa',
        :file_format  => 'yaml',
        :purge_config => true,
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

      it_behaves_like 'openstacklib::policy'
    end
  end

end
