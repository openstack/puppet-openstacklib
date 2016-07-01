require 'spec_helper'

describe 'openstacklib::defaults', type: :class do
  on_supported_os.each do |os, facts|
    let(:pre_condition) do
      <<-eof
package { 'my_virt_package' :
  ensure => present,
  tag   => 'openstack'
}
        eof
    end

    context "Puppet < 4.0.0" do
      context "on #{os}" do
        let(:facts) { facts.merge(:puppetversion => '3.8.0') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openstacklib::defaults') }
        it { is_expected.to contain_package('my_virt_package')
                             .with(:allow_virtual => true)}
      end
    end
    context "Puppet >= 4.0.0" do
      context "on #{os}" do
        let(:facts) { facts.merge(:puppetversion => '4.0.0') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openstacklib::defaults') }
        it { is_expected.to contain_package('my_virt_package')
                             .without(:allow_virtual)}
      end
    end
  end
end
