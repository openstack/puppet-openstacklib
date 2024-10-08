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
    credentials = double('credentials')
    allow(credentials).to receive(:to_env).and_return({
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
      expect(provider.class).to receive(:openstack)
          .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
          .and_return list_data
      response = Puppet::Provider::Openstack.request('project', 'list', ['--long'])
      expect(response.first[:description]).to eq 'Test tenant'
    end

    it 'makes a successful show request' do
      expect(provider.class).to receive(:openstack)
          .with('project', 'show', '--format', 'shell', ['1cb05cfed7c24279be884ba4f6520262'])
          .and_return show_data
      response = Puppet::Provider::Openstack.request('project', 'show', ['1cb05cfed7c24279be884ba4f6520262'])
      expect(response[:description]).to eq 'Test tenant'
    end

    it 'makes a successful set request' do
      expect(provider.class).to receive(:openstack)
          .with('project', 'set', ['--name', 'new name', '1cb05cfed7c24279be884ba4f6520262'])
          .and_return ''
      response = Puppet::Provider::Openstack.request('project', 'set', ['--name', 'new name', '1cb05cfed7c24279be884ba4f6520262'])
      expect(response).to eq ''
    end

    it 'uses provided credentials' do
      expect(Puppet::Util).to receive(:withenv).with(credentials.to_env)
      Puppet::Provider::Openstack.request('project', 'list', ['--long'], credentials)
    end

    it 'redacts sensitive data from an exception message' do
      e1 = Puppet::ExecutionFailure.new "Execution of 'openstack user create --format shell hello --password world --enable --email foo@example.com --domain Default' returned 1: command failed"
      expect do
        Puppet::Provider::Openstack.redact_and_raise(e1)
      end.to raise_error(Puppet::ExecutionFailure, /Execution of \'openstack user create --format shell hello --password \[redacted secret\] --enable --email foo@example.com --domain Default/)
      e2 = Puppet::ExecutionFailure.new "Execution of 'openstack user create --format shell hello --password world' returned 1: command failed"
      expect do
        Puppet::Provider::Openstack.redact_and_raise(e2)
      end.to raise_error(Puppet::ExecutionFailure, /Execution of \'openstack user create --format shell hello --password \[redacted secret\]\' returned/)
    end

    it 'redacts password in execution output on exception' do
      allow(provider.class).to receive(:execute)
          .and_raise(Puppet::ExecutionFailure, "Execution of '/usr/bin/openstack user create --format shell hello --password world --enable --email foo@example.com --domain Default' returned 1: command failed")
      expect do
        Puppet::Provider::Openstack.request('user', 'create', ['hello', '--password', 'world', '--enable', '--email', 'foo@example.com', '--domain', 'Default'])
      end.to raise_error Puppet::ExecutionFailure, "Execution of '/usr/bin/openstack user create --format shell hello --password [redacted secret] --enable --email foo@example.com --domain Default' returned 1: command failed"
    end

    context 'on connection errors' do
      it 'retries the failed command' do
        allow(provider.class).to receive(:openstack)
            .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
            .and_invoke(
              lambda { |*args| raise Puppet::ExecutionFailure, 'Unable to establish connection' },
              lambda { |*args| return list_data }
            )
        expect(provider.class).to receive(:sleep).with(10).and_return(nil)
        response = Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq 'Test tenant'
      end

      it 'fails after the timeout and redacts' do
        expect(provider.class).to receive(:execute)
            .and_raise(Puppet::ExecutionFailure, "Execution of 'openstack user create foo --password secret' returned 1: command failed")
            .exactly(6).times
        allow(provider.class).to receive(:sleep)
        allow(provider.class).to receive(:current_time)
            .and_return(0, 10, 20, 100, 200, 300, 400)
        expect do
          Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        end.to raise_error Puppet::ExecutionFailure, /Execution of \'openstack user create foo --password \[redacted secret\]\' returned 1/
      end

      it 'fails after the timeout' do
        expect(provider.class).to receive(:openstack)
            .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
            .and_raise(Puppet::ExecutionFailure, 'Unable to establish connection')
            .exactly(6).times
        allow(provider.class).to receive(:sleep)
        allow(provider.class).to receive(:current_time)
            .and_return(0, 10, 20, 100, 200, 300, 400)
        expect do
          Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        end.to raise_error Puppet::ExecutionFailure, /Unable to establish connection/
      end

      it 'does not retry non-idempotent commands' do
        expect(provider.class).to receive(:openstack)
            .with('project', 'create', '--format', 'shell', ['--quiet'])
            .and_raise(Puppet::ExecutionFailure, 'Unable to establish connection')
            .exactly(1).times
        expect(provider.class).to receive(:sleep).never
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
        allow(provider.class).to receive(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
                      .and_raise(Puppet::ExecutionFailure, 'Could not find user: test (HTTP 401)')
        expect do
          Puppet::Provider::Openstack.request('project', 'list', ['--long'])
        end.to raise_error(Puppet::Error::OpenstackUnauthorizedError, /Could not authenticate/)
      end

      it 'should raise an error with not authorized to perform' do
        allow(provider.class).to receive(:openstack)
                      .with('role', 'list', '--quiet', '--format', 'csv', ['--long'])
                      .and_raise(Puppet::ExecutionFailure, 'You are not authorized to perform the requested action: identity:list_grants (HTTP 403)')
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

  describe '#parse_python_dict' do
    it 'should return a hash when provided with a python dict' do
      s = "{'key': 'value', 'key2': 'value2'}"
      expect(Puppet::Provider::Openstack.parse_python_dict(s)).to eq({'key'=>'value', 'key2'=>'value2'})

      s = "{'key': True, 'key2': 'value2'}"
      expect(Puppet::Provider::Openstack.parse_python_dict(s)).to eq({'key'=>true, 'key2'=>'value2'})

      s = "{'key': 'value', 'key2': True}"
      expect(Puppet::Provider::Openstack.parse_python_dict(s)).to eq({'key'=>'value', 'key2'=>true})

      s = "{'key': False, 'key2': 'value2'}"
      expect(Puppet::Provider::Openstack.parse_python_dict(s)).to eq({'key'=>false, 'key2'=>'value2'})

      s = "{'key': 'value', 'key2': False}"
      expect(Puppet::Provider::Openstack.parse_python_dict(s)).to eq({'key'=>'value', 'key2'=>false})
    end
  end
end
