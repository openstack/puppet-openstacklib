require 'spec_helper'

describe 'openstacklib::defaults' do
  shared_examples 'openstacklib::defaults' do
    context 'with defaults' do
      it { should contain_class('openstacklib::defaults') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'openstacklib::defaults'
    end
  end
end
