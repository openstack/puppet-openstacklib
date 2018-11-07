require 'spec_helper'

describe 'openstacklib::db::mysql' do
  let :pre_condition do
    'include mysql::server'
  end

  let (:title) { 'nova' }

  let :required_params do
    {
      :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601'
    }
  end

  shared_examples 'openstacklib::db::mysql examples' do
    context 'with only required parameters' do
      let :params do
        required_params
      end

      it { should contain_mysql_database(title).with(
        :charset => 'utf8',
        :collate => 'utf8_general_ci'
      )}

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user        => title,
        :database    => title,
        :privileges  => 'ALL',
        :tls_options => ['NONE'],
      )}
    end

    context 'with overriding dbname parameter' do
      let :params do
        required_params.merge!( :dbname => 'foobar' )
      end

      it { should contain_mysql_database(params[:dbname]).with(
        :charset => 'utf8',
        :collate => 'utf8_general_ci'
      )}

      it { should contain_openstacklib__db__mysql__host_access("#{params[:dbname]}_127.0.0.1").with(
        :user         => title,
        :database     => params[:dbname],
        :privileges   => 'ALL',
        :create_user  => true,
        :create_grant => true,
        :tls_options  => ['NONE'],
      )}
    end

    context 'with overriding user parameter' do
      let :params do
        required_params.merge!( :user => 'foobar' )
      end

      it { should contain_mysql_database(title).with(
        :charset => 'utf8',
        :collate => 'utf8_general_ci'
      )}

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user         => params[:user],
        :database     => title,
        :privileges   => 'ALL',
        :create_user  => true,
        :create_grant => true,
        :tls_options  => ['NONE'],
      )}
    end

    context 'when overriding charset parameter' do
      let :params do
        required_params.merge!( :charset => 'latin1' )
      end

      it { should contain_mysql_database(title).with_charset(params[:charset]) }
    end

    context 'when omitting the required parameter password_hash' do
      let :params do
        {}
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'when notifying other resources' do
      let :pre_condition do
        'exec {"nova-db-sync":}'
      end

      let :params do
        required_params.merge!( :notify => 'Exec[nova-db-sync]' )
      end

      it { should contain_exec('nova-db-sync').that_subscribes_to("Openstacklib::Db::Mysql[#{title}]") }
    end

    context 'when required for other openstack services' do
      let :pre_condition do
        'service {"keystone":}'
      end

      let :title do
        'keystone'
      end

      let :params do
        required_params.merge!( :before => 'Service[keystone]' )
      end

      it { should contain_service('keystone').that_requires("Openstacklib::Db::Mysql[keystone]") }
    end

    context "overriding allowed_hosts parameter with array value" do
      let :params do
        required_params.merge!( :allowed_hosts => ['127.0.0.1', '%'] )
      end

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user          => title,
        :password_hash => params[:password_hash],
        :database      => title
      )}

      it { should contain_openstacklib__db__mysql__host_access("#{title}_%").with(
        :user          => title,
        :password_hash => params[:password_hash],
        :database      => title
      )}
    end

    context "overriding allowed_hosts parameter with string value" do
      let :params do
        required_params.merge!( :allowed_hosts => '192.168.1.1' )
      end

      it { should contain_openstacklib__db__mysql__host_access("#{title}_192.168.1.1").with(
        :user          => title,
        :password_hash => params[:password_hash],
        :database      => title
      )}
    end

    context "overriding allowed_hosts parameter equals to host param " do
      let :params do
        required_params.merge!( :allowed_hosts => '127.0.0.1' )
      end

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user          => title,
        :password_hash => params[:password_hash],
        :database      => title
      )}
    end

    context 'with skipping user creation' do
      let :params do
        required_params.merge!( :create_user => false )
      end

      it { should contain_mysql_database(title).with(
        :charset => 'utf8',
        :collate => 'utf8_general_ci'
      )}

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user         => title,
        :database     => title,
        :privileges   => 'ALL',
        :create_user  => false,
        :create_grant => true,
      )}
    end

    context 'with skipping grant creation' do
      let :params do
        required_params.merge!( :create_grant => false )
      end

      it { should contain_mysql_database(title).with(
        :charset => 'utf8',
        :collate => 'utf8_general_ci'
      )}

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user         => title,
        :database     => title,
        :privileges   => 'ALL',
        :create_user  => true,
        :create_grant => false,
      )}
    end

    context 'with skipping user and grant creation' do
      let :params do
        required_params.merge!( :create_user  => false,
                                :create_grant => false )
      end

      it { should contain_mysql_database(title).with(
        :charset => 'utf8',
        :collate => 'utf8_general_ci'
      )}

      it { should_not contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1") }
    end

    context 'overriding tls_options' do
      let :params do
        required_params.merge!( :tls_options => ['SSL'] )
      end

      it { should contain_openstacklib__db__mysql__host_access("#{title}_127.0.0.1").with(
        :user          => title,
        :password_hash => params[:password_hash],
        :database      => title,
        :tls_options   => ['SSL'],
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

      it_behaves_like 'openstacklib::db::mysql examples'
    end
  end
end
