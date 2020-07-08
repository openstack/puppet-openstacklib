require 'spec_helper'

describe 'openstacklib::policy' do
  shared_examples 'openstacklib::policy' do
    context 'with basic configuration' do
      let :params do
        {
          :policies => {
            'foo' => {
              'file_path' => '/etc/nova/policy.json',
              'key'       => 'context_is_admin',
              'value'     => 'foo:bar'
            }
          }
        }
      end

      it { should contain_openstacklib__policy__base('foo').with(
        :file_path => '/etc/nova/policy.json',
        :key       => 'context_is_admin',
        :value     => 'foo:bar'
      )}
    end
    context 'with yaml configuration' do
      let :params do
        {
          :policies => {
            'foo' => {
              'file_path' => '/etc/octavia/policy.yaml',
              'key'       => 'context_is_admin',
              'value'     => 'foo:bar'
            }
          }
        }
      end

      it { should contain_openstacklib__policy__base('foo').with(
        :file_path => '/etc/octavia/policy.yaml',
        :key       => 'context_is_admin',
        :value     => 'foo:bar'
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
