require 'spec_helper'

describe 'openstacklib::db::postgresql' do
  let (:title) { 'nova' }

  let :required_params do
    {
      :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601'
    }
  end

  let (:pre_condition) do
    "include postgresql::server"
  end

  shared_examples 'openstacklib::db::postgresql examples' do
    context 'with only required parameters' do
      let :params do
        required_params
      end

      it { should contain_postgresql__server__db(title).with(
        :user     => title,
        :password => params[:password_hash]
      )}
    end

    context 'when overriding encoding' do
      let :params do
        required_params.merge!( :encoding => 'latin1' )
      end

      it { should contain_postgresql__server__db(title).with_encoding(params[:encoding]) }
    end

    context 'when omitting the required parameter password_hash' do
      let :params do
        {}
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'when notifying other resources' do
      let :pre_condition do
        "include postgresql::server
         exec { 'nova-db-sync': }"
      end

      let :params do
        required_params.merge!( :notify => 'Exec[nova-db-sync]' )
      end

      it { should contain_exec('nova-db-sync').that_subscribes_to("Openstacklib::Db::Postgresql[#{title}]") }
    end

    context 'when required for other openstack services' do
      let :pre_condition do
        "include postgresql::server
        service {'keystone':}"
      end

      let :title do
        'keystone'
      end

      let :params do
        required_params.merge!( :before => 'Service[keystone]' )
      end

      it { should contain_service('keystone').that_requires("Openstacklib::Db::Postgresql[keystone]") }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'openstacklib::db::postgresql examples'
    end
  end
end
