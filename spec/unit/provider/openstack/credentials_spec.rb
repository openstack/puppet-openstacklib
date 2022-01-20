require 'puppet'
require 'spec_helper'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/credentials'


describe Puppet::Provider::Openstack::Credentials do

  let(:creds) do
    creds = Puppet::Provider::Openstack::CredentialsV3.new
  end

  describe "#set with valid value" do
    it 'works with valid value' do
      expect(creds.class.defined?('auth_url')).to be_truthy
      creds.set('auth_url', 'http://localhost:5000/v2.0')
      expect(creds.auth_url).to eq('http://localhost:5000/v2.0')
    end
  end

  describe "#set with invalid value" do
    it 'works with invalid value' do
      expect(creds.class.defined?('foo')).to be_falsey
      creds.set('foo', 'junk')
      expect(creds.respond_to?(:foo)).to be_falsey
      expect(creds.instance_variable_defined?(:@foo)).to be_falsey
      expect { creds.foo }.to raise_error(NoMethodError, /undefined method/)
    end
  end

  describe '#service_token_set?' do
    context "with service credentials" do
      it 'is successful' do
        creds.token = 'token'
        creds.endpoint = 'endpoint'
        expect(creds.service_token_set?).to be_truthy
        expect(creds.user_password_set?).to be_falsey
      end

      it 'fails' do
        creds.token = 'token'
        expect(creds.service_token_set?).to be_falsey
        expect(creds.user_password_set?).to be_falsey
      end
    end
  end

  describe '#password_set?' do
    context "with user credentials" do
      it 'is successful with project scope credential' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.service_token_set?).to be_falsey
      end

      it 'is successful with project scope credential' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.domain_name = 'domain_name'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.service_token_set?).to be_falsey
      end

      it 'is successful with system scope credential' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.system_scope = 'all'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.service_token_set?).to be_falsey
      end

      it 'is successful with cloud' do
        creds.cloud = 'openstack'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.service_token_set?).to be_falsey
      end

      it 'fails' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        expect(creds.user_password_set?).to be_falsey
        expect(creds.service_token_set?).to be_falsey
      end
    end
  end

  describe '#set?' do
    context "without any credential" do
      it 'fails' do
        expect(creds.set?).to be_falsey
      end
    end
  end

  describe '#version' do
    it 'is version 3' do
      expect(creds.version).to eq('3')
    end
  end

  describe '#unset' do
    context "with all instance variables set" do
      it 'resets all but the identity_api_version' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        creds.domain_name = 'domain_name'
        creds.system_scope = 'system_scope'
        creds.username = 'username'
        creds.token = 'token'
        creds.endpoint = 'endpoint'
        creds.region_name = 'region_name'
        creds.identity_api_version = 'identity_api_version'
        creds.cloud = 'openstack'
        creds.client_config_file = '/etc/openstack/clouds.yaml'
        creds.unset
        expect(creds.auth_url).to eq('')
        expect(creds.password).to eq('')
        expect(creds.project_name).to eq('')
        expect(creds.domain_name).to eq('')
        expect(creds.system_scope).to eq('')
        expect(creds.username).to eq('')
        expect(creds.token).to eq('')
        expect(creds.endpoint).to eq('')
        expect(creds.region_name).to eq('')
        expect(creds.identity_api_version).to eq('identity_api_version')
        expect(creds.cloud).to eq('')
        expect(creds.client_config_file).to eq('')
        newcreds = Puppet::Provider::Openstack::CredentialsV3.new
        expect(newcreds.identity_api_version).to eq('3')
      end
    end
  end

  describe '#to_env' do
    context "with an exhaustive data set" do
      it 'successfully returns content' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        creds.domain_name = 'domain_name'
        creds.system_scope = 'all'
        creds.username = 'username'
        creds.token = 'token'
        creds.endpoint = 'endpoint'
        creds.region_name = 'Region1'
        creds.identity_api_version = 'identity_api_version'
        creds.cloud = 'openstack'
        creds.client_config_file = '/etc/openstack/clouds.yaml'
        expect(creds.to_env).to eq({
          'OS_USERNAME'             => 'username',
          'OS_PASSWORD'             => 'password',
          'OS_PROJECT_NAME'         => 'project_name',
          'OS_DOMAIN_NAME'          => 'domain_name',
          'OS_SYSTEM_SCOPE'         => 'all',
          'OS_AUTH_URL'             => 'auth_url',
          'OS_TOKEN'                => 'token',
          'OS_ENDPOINT'             => 'endpoint',
          'OS_REGION_NAME'          => 'Region1',
          'OS_IDENTITY_API_VERSION' => 'identity_api_version',
          'OS_CLOUD'                => 'openstack',
          'OS_CLIENT_CONFIG_FILE'   => '/etc/openstack/clouds.yaml',
        })
      end
    end
  end

  describe 'using v3' do
    let(:creds) do
      creds = Puppet::Provider::Openstack::CredentialsV3.new
    end
    describe 'with v3' do
      it 'uses v3 identity api' do
        creds.identity_api_version == '3'
      end
    end
    describe '#password_set? with username and project_name' do
      it 'is successful' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.scope).to eq('project')
      end
    end
    describe '#password_set? with username and domain_name' do
      it 'is successful' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.domain_name = 'domain_name'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.scope).to eq('domain')
      end
    end
    describe '#password_set? with username and system_scope' do
      it 'is successful' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.system_scope = 'all'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.scope).to eq('system')
      end
    end
    describe '#password_set? with cloud' do
      it 'is successful' do
        creds.cloud = 'openstack'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.scope).to eq(nil)
      end
    end
    describe '#password_set? with user_id and project_id' do
      it 'is successful' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_id = 'projid'
        creds.user_id = 'userid'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.scope).to eq('project')
      end
    end
    describe '#password_set? with user_id and domain_id' do
      it 'is successful' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.domain_id = 'domid'
        creds.user_id = 'userid'
        expect(creds.user_password_set?).to be_truthy
        expect(creds.scope).to eq('domain')
      end
    end
  end
end
