require 'spec_helper'

describe 'openstacklib::policy::base' do


  shared_examples_for 'openstacklib::policy::base' do
    context 'with some basic parameters' do
      let :title do
        'nova-contest_is_admin'
      end

      let :params do
        {
          :file_path  => '/etc/nova/policy.json',
          :key        => 'context_is_admin or owner',
          :value      => 'foo:bar',
          :file_mode  => '0644',
          :file_user  => 'foo',
          :file_group => 'bar'
        }
      end

      it {
        is_expected.to contain_file('/etc/nova/policy.json').with(
          :mode  => '0644',
          :owner => 'foo',
          :group => 'bar')
      }

      it 'configures (modifies) the proper policy' do
        is_expected.to contain_augeas('/etc/nova/policy.json-context_is_admin or owner-foo:bar').with(
          'lens'    => 'Json.lns',
          'incl'    => '/etc/nova/policy.json',
          'changes' => 'set dict/entry[*][.="context_is_admin or owner"]/string "foo:bar"',
        )
      end

      it 'configures (adds) the proper policy' do
        is_expected.to contain_augeas('/etc/nova/policy.json-context_is_admin or owner-foo:bar-add').with(
          'lens'    => 'Json.lns',
          'incl'    => '/etc/nova/policy.json',
          'changes' => [
              'set dict/entry[last()+1] "context_is_admin or owner"',
              'set dict/entry[last()]/string "foo:bar"'
          ],
          'onlyif' => 'match dict/entry[*][.="context_is_admin or owner"] size == 0'
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

      it_configures 'openstacklib::policy::base'
    end
  end

end

