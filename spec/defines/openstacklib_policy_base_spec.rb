require 'spec_helper'

describe 'openstacklib::policy::base' do
  shared_examples 'openstacklib::policy::base' do
    context 'with policy.json' do
      let :title do
        'nova-contest_is_admin'
      end

      let :params do
        {
          :file_path   => '/etc/nova/policy.json',
          :key         => 'context_is_admin or owner',
          :value       => 'foo:bar',
          :file_mode   => '0644',
          :file_user   => 'foo',
          :file_group  => 'bar',
          :file_format => 'json',
        }
      end

      it { should contain_file('/etc/nova/policy.json').with(
        :mode  => '0644',
        :owner => 'foo',
        :group => 'bar'
      )}

      it { should contain_augeas('/etc/nova/policy.json-context_is_admin or owner-foo:bar').with(
        :lens    => 'Json.lns',
        :incl    => '/etc/nova/policy.json',
        :changes => 'set dict/entry[*][.="context_is_admin or owner"]/string "foo:bar"',
      )}

      it { should contain_augeas('/etc/nova/policy.json-context_is_admin or owner-foo:bar-add').with(
        :lens    => 'Json.lns',
        :incl    => '/etc/nova/policy.json',
        :changes => [
          'set dict/entry[last()+1] "context_is_admin or owner"',
          'set dict/entry[last()]/string "foo:bar"'
        ],
        :onlyif  => 'match dict/entry[*][.="context_is_admin or owner"] size == 0'
      )}
    end

    context 'with policy.yaml' do
      let :title do
        'nova-contest_is_admin'
      end

      let :params do
        {
          :file_path   => '/etc/nova/policy.yaml',
          :key         => 'context_is_admin or owner',
          :value       => 'foo:bar',
          :file_mode   => '0644',
          :file_user   => 'foo',
          :file_group  => 'bar',
          :file_format => 'yaml',
        }
      end

      it { should contain_file('/etc/nova/policy.yaml').with(
        :mode  => '0644',
        :owner => 'foo',
        :group => 'bar'
      )}

      it { should contain_file_line('/etc/nova/policy.yaml-context_is_admin or owner').with(
        :path  => '/etc/nova/policy.yaml',
        :line  => '\'context_is_admin or owner\': \'foo:bar\'',
        :match => '^[\'"]?context_is_admin or owner(?!:)[\'"]?\s*:.+'
      ) }

      context 'with single-quotes in value' do
        before do
          params.merge!({
            :value => 'foo:\'bar\''
          })
        end

        it { should contain_file_line('/etc/nova/policy.yaml-context_is_admin or owner').with(
          :path  => '/etc/nova/policy.yaml',
          :line  => '\'context_is_admin or owner\': \'foo:\'\'bar\'\'\'',
          :match => '^[\'"]?context_is_admin or owner(?!:)[\'"]?\s*:.+'
        ) }
      end

      context 'with pre-formatted single-quotes in value' do
        before do
          params.merge!({
            :value => 'foo:\'\'bar\'\''
          })
        end

        it { should contain_file_line('/etc/nova/policy.yaml-context_is_admin or owner').with(
          :path  => '/etc/nova/policy.yaml',
          :line  => '\'context_is_admin or owner\': \'foo:\'\'bar\'\'\'',
          :match => '^[\'"]?context_is_admin or owner(?!:)[\'"]?\s*:.+'
        ) }
      end
    end

    context 'with json file_path and yaml file format' do
      let :title do
        'nova-contest_is_admin'
      end

      let :params do
        {
          :file_path   => '/etc/nova/policy.json',
          :key         => 'context_is_admin or owner',
          :value       => 'foo:bar',
          :file_mode   => '0644',
          :file_user   => 'foo',
          :file_group  => 'bar',
          :file_format => 'yaml',
        }
      end

      it { should raise_error(Puppet::Error) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'openstacklib::policy::base'
    end
  end
end
