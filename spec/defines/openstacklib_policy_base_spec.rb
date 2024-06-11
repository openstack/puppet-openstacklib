require 'spec_helper'

describe 'openstacklib::policy::base' do
  shared_examples 'openstacklib::policy::base' do
    let :title do
      'context_is_admin or owner'
    end

    context 'with policy.yaml' do
      let :params do
        {
          :file_path  => '/etc/nova/policy.yaml',
          :value      => 'foo:bar',
          :file_mode  => '0644',
          :file_user  => 'foo',
          :file_group => 'bar',
        }
      end

      it { should contain_openstacklib__policy__default('/etc/nova/policy.yaml').with(
        :file_mode    => '0644',
        :file_user    => 'foo',
        :file_group   => 'bar',
        :file_format  => 'yaml',
        :purge_config => false,
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

    context 'with purge_config enabled' do
      let :params do
        {
          :file_path    => '/etc/nova/policy.yaml',
          :value        => 'foo:bar',
          :file_mode    => '0644',
          :file_user    => 'foo',
          :file_group   => 'bar',
          :purge_config => true,
        }
      end

      it { should contain_openstacklib__policy__default('/etc/nova/policy.yaml').with(
        :file_mode    => '0644',
        :file_user    => 'foo',
        :file_group   => 'bar',
        :file_format  => 'yaml',
        :purge_config => true,
      )}
    end

    context 'with key overridden' do
      let :params do
        {
          :file_path   => '/etc/nova/policy.yaml',
          :key         => 'context_is_admin',
          :value       => 'foo:bar',
          :file_mode   => '0644',
          :file_user   => 'foo',
          :file_group  => 'bar',
          :file_format => 'yaml',
        }
      end

      it { should contain_file_line('/etc/nova/policy.yaml-context_is_admin').with(
        :path  => '/etc/nova/policy.yaml',
        :line  => '\'context_is_admin\': \'foo:bar\'',
        :match => '^[\'"]?context_is_admin(?!:)[\'"]?\s*:.+'
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

      it_behaves_like 'openstacklib::policy::base'
    end
  end
end
