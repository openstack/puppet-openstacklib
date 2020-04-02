require 'spec_helper'

describe 'openstacklib::db::mysql::host_access' do
  let :pre_condition do
    "include mysql::server\n" +
    "openstacklib::db::mysql { 'nova':\n" +
    "  password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601'}"
  end

  shared_examples 'openstacklib::db::mysql::host_access examples' do
    context 'with required parameters' do
      let (:title) { 'nova_10.0.0.1' }

      let :params do
        {
          :user          => 'foobar',
          :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601',
          :database      => 'nova',
          :privileges    => 'ALL'
        }
      end

      it { should contain_mysql_user("#{params[:user]}@10.0.0.1").with(
        :plugin        => nil,
        :password_hash => params[:password_hash],
        :tls_options   => ['NONE']
      )}

      it { should contain_mysql_grant("#{params[:user]}@10.0.0.1/#{params[:database]}.*").with(
        :user       => "#{params[:user]}@10.0.0.1",
        :privileges => 'ALL',
        :table      => "#{params[:database]}.*"
      )}
    end

    context 'with overriding authentication plugin' do
      let (:title) { 'nova_10.0.0.1' }

      let :params do
        {
          :user          => 'foobar',
          :plugin        => 'mysql_native_password',
          :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601',
          :database      => 'nova',
          :privileges    => 'ALL'
        }
      end

      it { should contain_mysql_user("#{params[:user]}@10.0.0.1").with(
        :plugin        => params[:plugin],
        :password_hash => params[:password_hash],
        :tls_options   => ['NONE']
      )}

      it { should contain_mysql_grant("#{params[:user]}@10.0.0.1/#{params[:database]}.*").with(
        :user       => "#{params[:user]}@10.0.0.1",
        :privileges => 'ALL',
        :table      => "#{params[:database]}.*"
      )}
    end

    context 'with skipping user creation' do
      let (:title) { 'nova_10.0.0.1' }

      let :params do
        {
          :user          => 'foobar',
          :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601',
          :database      => 'nova',
          :privileges    => 'ALL',
          :create_user   => false,
        }
      end

      it { should_not contain_mysql_user("#{params[:user]}@10.0.0.1") }

      it { should contain_mysql_grant("#{params[:user]}@10.0.0.1/#{params[:database]}.*").with(
        :user       => "#{params[:user]}@10.0.0.1",
        :privileges => 'ALL',
        :table      => "#{params[:database]}.*"
      )}
    end

    context 'with skipping grant creation' do
      let (:title) { 'nova_10.0.0.1' }

      let :params do
        {
          :user          => 'foobar',
          :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601',
          :database      => 'nova',
          :privileges    => 'ALL',
          :create_grant  => false,
        }
      end

      it { should contain_mysql_user("#{params[:user]}@10.0.0.1").with(
        :plugin        => nil,
        :password_hash => params[:password_hash]
      )}

      it { should_not contain_mysql_grant("#{params[:user]}@10.0.0.1/#{params[:database]}.*") }
    end

    context 'with skipping user and grant creation' do
      let (:title) { 'nova_10.0.0.1' }

      let :params do
        {
          :user          => 'foobar',
          :password_hash => 'AA1420F182E88B9E5F874F6FBE7459291E8F4601',
          :database      => 'nova',
          :privileges    => 'ALL',
          :create_user   => false,
          :create_grant  => false,
        }
      end

      it { should_not contain_mysql_user("#{params[:user]}@10.0.0.1") }
      it { should_not contain_mysql_grant("#{params[:user]}@10.0.0.1/#{params[:database]}.*") }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'openstacklib::db::mysql::host_access examples'
    end
  end

end
