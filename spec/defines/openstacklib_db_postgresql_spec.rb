require 'spec_helper'

describe 'openstacklib::db::postgresql' do
  let (:title) { 'nova' }

  let :required_params do
    { :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601' }
  end

  let (:pre_condition) do
    "include ::postgresql::server"
  end

  shared_examples 'openstacklib::db::postgresql examples' do
    context 'with only required parameters' do
      let :params do
        required_params
      end

      it { is_expected.to contain_postgresql__server__db(title).with(
        :user     => title,
        :password => params[:password_hash]
      )}
    end

    context 'when overriding encoding' do
      let :params do
        { :encoding => 'latin1' }.merge(required_params)
      end
      it { is_expected.to contain_postgresql__server__db(title).with_encoding(params[:encoding]) }
    end

    context 'when omitting the required parameter password_hash' do
      let :params do
        required_params.delete(:password_hash)
      end

      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    context 'when notifying other resources' do
      let :pre_condition do
        "include ::postgresql::server
         exec { 'nova-db-sync': }"
      end
      let :params do
        { :notify => 'Exec[nova-db-sync]'}.merge(required_params)
      end

      it {is_expected.to contain_exec('nova-db-sync').that_subscribes_to("Openstacklib::Db::Postgresql[#{title}]") }
    end

    context 'when required for other openstack services' do
      let :pre_condition do
        "include ::postgresql::server
        service {'keystone':}"
      end
      let :title do
        'keystone'
      end
      let :params do
        { :before => 'Service[keystone]'}.merge(required_params)
      end

      it { is_expected.to contain_service('keystone').that_requires("Openstacklib::Db::Postgresql[keystone]") }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'openstacklib::db::postgresql examples'
    end
  end

end
