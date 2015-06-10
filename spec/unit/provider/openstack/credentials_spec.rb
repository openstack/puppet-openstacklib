require 'puppet'
require 'spec_helper'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/credentials'


describe Puppet::Provider::Openstack::Credentials do

  let(:creds) do
    creds = Puppet::Provider::Openstack::CredentialsV2_0.new
  end

  describe '#service_token_set?' do
    context "with service credentials" do
      it 'is successful' do
        creds.token = 'token'
        creds.url = 'url'
        expect(creds.service_token_set?).to be_truthy
      end
    end
  end

  describe '#password_set?' do
    context "with user credentials" do
      it 'is successful' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        creds.username = 'username'
        expect(creds.user_password_set?).to be_truthy
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

  describe '#to_env' do
    context "with an exhaustive data set" do
      it 'successfully returns content' do
        creds.auth_url = 'auth_url'
        creds.password = 'password'
        creds.project_name = 'project_name'
        creds.username = 'username'
        creds.token = 'token'
        creds.url = 'url'
        creds.identity_api_version = 'identity_api_version'
        expect(creds.auth_url).to eq("auth_url")
        expect(creds.password).to eq("password")
        expect(creds.project_name).to eq("project_name")
        expect(creds.username).to eq("username")
        expect(creds.token).to eq('token')
        expect(creds.url).to eq('url')
        expect(creds.identity_api_version).to eq('identity_api_version')
      end
    end
  end
end
