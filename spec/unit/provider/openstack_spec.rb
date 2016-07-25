require 'puppet'
require 'spec_helper'
require 'puppet/provider/openstack'

describe Puppet::Provider::Openstack do
  before(:each) do
    ENV['OS_USERNAME'] = nil
    ENV['OS_PASSWORD'] = nil
    ENV['OS_PROJECT_NAME'] = nil
    ENV['OS_AUTH_URL'] = nil
  end

  let(:type) do
    Puppet::Type.newtype(:test_resource) do
      newparam(:name, :namevar => true)
      newparam(:log_file)
    end
  end

  let(:credentials) do
    credentials = mock('credentials')
    credentials.stubs(:to_env).returns({
                                           'OS_USERNAME' => 'user',
                                           'OS_PASSWORD' => 'password',
                                           'OS_PROJECT_NAME' => 'project',
                                           'OS_AUTH_URL' => 'http://url',
                                       })
    credentials
  end

  let(:list_data) do
    <<-eos
"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
    eos
  end

  let(:show_data) do
    <<-eos
description="Test tenant"
enabled="True"
id="1cb05cfed7c24279be884ba4f6520262"
name="test"
    eos
  end

  describe '#request' do
    let(:resource_attrs) do
      {
          :name => 'stubresource',
      }
    end

    let(:provider) do
      Puppet::Provider::Openstack.new(type.new(resource_attrs))
    end

    it 'makes a successful list request' do
      provider.class.expects(:openstack)
          .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
          .returns list_data
      response = Puppet::Provider::Openstack.request('project', 'list', ['--long'])
      expect(response.first[:description]).to eq 'Test tenant'
    end

    it 'makes a successful show request' do
      provider.class.expects(:openstack)
          .with('project', 'show', '--format', 'shell', ['1cb05cfed7c24279be884ba4f6520262'])
          .returns show_data
      response = Puppet::Provider::Openstack.request('project', 'show', ['1cb05cfed7c24279be884ba4f6520262'])
      expect(response[:description]).to eq 'Test tenant'
    end

    it 'makes a successful set request' do
      provider.class.expects(:openstack)
          .with('project', 'set', ['--name', 'new name', '1cb05cfed7c24279be884ba4f6520262'])
          .returns ''
      response = Puppet::Provider::Openstack.request('project', 'set', ['--name', 'new name', '1cb05cfed7c24279be884ba4f6520262'])
      expect(response).to eq ''
    end

    it 'uses provided credentials' do
      Puppet::Util.expects(:withenv).with(credentials.to_env)
      Puppet::Provider::Openstack.request('project', 'list', ['--long'], credentials)
    end

    context 'on connection errors' do
      it 'retries the failed command' do
        provider.class.stubs(:openstack)
            .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
            .raises(Puppet::ExecutionFailure, 'Unable to establish connection')
            .then
            .returns list_data
        provider.class.expects(:sleep).with(3).returns(nil)
        response = Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq 'Test tenant'
      end

      it 'fails after the timeout' do
        provider.class.expects(:openstack)
            .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
            .raises(Puppet::ExecutionFailure, 'Unable to establish connection')
            .times(3)
        provider.class.stubs(:sleep)
        provider.class.stubs(:current_time)
            .returns(0, 10, 10, 20, 20, 200, 200)
        expect do
          Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        end.to raise_error Puppet::ExecutionFailure, /Unable to establish connection/
      end

      it 'does not retry non-idempotent commands' do
        provider.class.expects(:openstack)
            .with('project', 'create', '--format', 'shell', ['--quiet'])
            .raises(Puppet::ExecutionFailure, 'Unable to establish connection')
            .then
            .returns list_data
        provider.class.expects(:sleep).never
        expect do
          Puppet::Provider::Openstack.request('project', 'create', ['--quiet'])
        end.to raise_error Puppet::ExecutionFailure, /Unable to establish connection/
      end

    end

    context 'catch unauthorized errors' do
      it 'should raise an error with non-existent user' do
        ENV['OS_USERNAME']     = 'test'
        ENV['OS_PASSWORD']     = 'abc123'
        ENV['OS_PROJECT_NAME'] = 'test'
        ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
                      .raises(Puppet::ExecutionFailure, 'Could not find user: test (HTTP 401)')
        expect do
          Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        end.to raise_error(Puppet::Error::OpenstackUnauthorizedError, /Could not authenticate/)
      end

      it 'should raise an error with not authorized to perform' do
        provider.class.stubs(:openstack)
                      .with('role', 'list', '--quiet', '--format', 'csv', ['--long'])
                      .raises(Puppet::ExecutionFailure, 'You are not authorized to perform the requested action: identity:list_grants (HTTP 403)')
        expect do
          Puppet::Provider::Openstack.request('role', 'list', ['--long'])
        end.to raise_error(Puppet::Error::OpenstackUnauthorizedError, /Could not authenticate/)
      end
    end
  end

  describe 'parse_csv' do
    context 'with mixed stderr' do
      text = "ERROR: Testing\n\"field\",\"test\",1,2,3\n"
      csv = Puppet::Provider::Openstack.parse_csv(text)
      it 'should ignore non-CSV text at the beginning of the input' do
        expect(csv).to be_kind_of(Array)
        expect(csv[0]).to match_array(%w(field test 1 2 3))
        expect(csv.size).to eq(1)
      end
    end

    context 'with \r\n line endings' do
      text = "ERROR: Testing\r\n\"field\",\"test\",1,2,3\r\n"
      csv = Puppet::Provider::Openstack.parse_csv(text)
      it 'ignore the carriage returns' do
        expect(csv).to be_kind_of(Array)
        expect(csv[0]).to match_array(%w(field test 1 2 3))
        expect(csv.size).to eq(1)
      end
    end

    context 'with embedded newlines' do
      text = "ERROR: Testing\n\"field\",\"te\nst\",1,2,3\n"
      csv = Puppet::Provider::Openstack.parse_csv(text)
      it 'should parse correctly' do
        expect(csv).to be_kind_of(Array)
        expect(csv[0]).to match_array(['field', "te\nst", '1', '2', '3'])
        expect(csv.size).to eq(1)
      end
    end
  end
end
