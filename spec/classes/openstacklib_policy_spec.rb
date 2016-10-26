require 'spec_helper'

describe 'openstacklib::policy' do

  shared_examples_for 'openstacklib::policy' do
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

      it 'configures the proper policy' do
        is_expected.to contain_openstacklib__policy__base('foo').with(
          :file_path => '/etc/nova/policy.json',
          :key       => 'context_is_admin',
          :value     => 'foo:bar'
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

      it_configures 'openstacklib::policy'
    end
  end

end
