require 'puppet'
require 'spec_helper'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'tempfile'

class Puppet::Provider::Openstack::AuthTester < Puppet::Provider::Openstack
  extend Puppet::Provider::Openstack::Auth
end

klass = Puppet::Provider::Openstack::AuthTester

describe Puppet::Provider::Openstack::Auth do

  let(:type) do
    Puppet::Type.newtype(:test_resource) do
      newparam(:name, :namevar => true)
      newparam(:log_file)
    end
  end

  let(:resource_attrs) do
    {
      :name => 'stubresource'
    }
  end

  let(:provider) do
    klass.new(type.new(resource_attrs))
  end

  before(:each) do
    ENV['OS_USERNAME']     = nil
    ENV['OS_PASSWORD']     = nil
    ENV['OS_PROJECT_NAME'] = nil
    ENV['OS_AUTH_URL']     = nil
    ENV['OS_TOKEN']        = nil
    ENV['OS_ENDPOINT']     = nil
  end

  describe '#set_credentials' do
    it 'adds keys to the object' do
      credentials = Puppet::Provider::Openstack::CredentialsV3.new
      set = { 'OS_USERNAME'             => 'user',
              'OS_PASSWORD'             => 'secret',
              'OS_PROJECT_NAME'         => 'tenant',
              'OS_AUTH_URL'             => 'http://127.0.0.1:5000',
              'OS_TOKEN'                => 'token',
              'OS_ENDPOINT'             => 'http://127.0.0.1:5000',
              'OS_IDENTITY_API_VERSION' => '2.0',
              'OS_NOT_VALID'            => 'notvalid'
        }
      klass.set_credentials(credentials, set)
      expect(credentials.to_env).to eq(
        "OS_AUTH_URL"             => "http://127.0.0.1:5000",
        "OS_IDENTITY_API_VERSION" => '2.0',
        "OS_PASSWORD"             => "secret",
        "OS_PROJECT_NAME"         => "tenant",
        "OS_TOKEN"                => "token",
        "OS_ENDPOINT"             => "http://127.0.0.1:5000",
        "OS_USERNAME"             => "user")
    end
  end

  describe '#rc_filename' do
    it 'returns RCFILENAME' do
      expect(klass.rc_filename).to eq("#{ENV['HOME']}/openrc")
    end
  end

  describe '#get_os_from_env' do
    context 'with Openstack environment variables set' do
      it 'provides a hash' do
        ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
        ENV['OS_PASSWORD']     = 'abc123'
        ENV['OS_PROJECT_NAME'] = 'test'
        ENV['OS_USERNAME']     = 'test'
        response = klass.get_os_vars_from_env
        expect(response).to eq({
          "OS_AUTH_URL"     => "http://127.0.0.1:5000",
          "OS_PASSWORD"     => "abc123",
          "OS_PROJECT_NAME" => "test",
          "OS_USERNAME"     => "test"})
      end
    end
  end

  describe '#get_os_vars_from_cloudsfile' do
    context 'with a clouds.yaml present' do
      it 'provides a hash' do
        expect(File).to receive(:exist?).with('/etc/openstack/puppet/clouds.yaml').and_return(true)

        response = klass.get_os_vars_from_cloudsfile('project')
        expect(response).to eq({
          'OS_CLOUD'              => 'project',
          'OS_CLIENT_CONFIG_FILE' => '/etc/openstack/puppet/clouds.yaml'
        })
      end
    end

    context 'with a admin-clouds.yaml present' do
      it 'provides a hash' do
        expect(File).to receive(:exist?).with('/etc/openstack/puppet/clouds.yaml').and_return(false)
        expect(File).to receive(:exist?).with('/etc/openstack/puppet/admin-clouds.yaml').and_return(true)

        response = klass.get_os_vars_from_cloudsfile('project')
        expect(response).to eq({
          'OS_CLOUD'              => 'project',
          'OS_CLIENT_CONFIG_FILE' => '/etc/openstack/puppet/admin-clouds.yaml'
        })
      end
    end

    context 'with a clouds.yaml not present' do
      it 'provides an empty hash' do
        expect(File).to receive(:exist?).with('/etc/openstack/puppet/clouds.yaml').and_return(false)
        expect(File).to receive(:exist?).with('/etc/openstack/puppet/admin-clouds.yaml').and_return(false)

        response = klass.get_os_vars_from_cloudsfile('project')
        expect(response).to eq({})
      end
    end
  end

  describe '#get_os_vars_from_rcfile' do
    context 'with a valid RC file' do
      it 'provides a hash' do
        content = "export OS_USERNAME='test'\nexport OS_PASSWORD='abc123'\nexport OS_PROJECT_NAME='test'\nexport OS_AUTH_URL='http://127.0.0.1:5000'"
        filename = 'file'
        expect(File).to receive(:exist?).with('file').and_return(true)
        expect(File).to receive(:open).with('file').and_return(StringIO.new(content))

        response = klass.get_os_vars_from_rcfile(filename)
        expect(response).to eq({
          "OS_AUTH_URL"     => "http://127.0.0.1:5000",
          "OS_PASSWORD"     => "abc123",
          "OS_PROJECT_NAME" => "test",
          "OS_USERNAME"     => "test"})
      end
    end

    context 'with a valid RC file with extra code in it' do
      it 'provides a hash' do
        content = "export OS_USERNAME='test'\nexport OS_PASSWORD='abc123'\nexport OS_PROJECT_NAME='test'\nexport OS_AUTH_URL='http://127.0.0.1:5000'\n_openstack() {\n foo\n} "
        filename = 'file'
        expect(File).to receive(:exist?).with('file').and_return(true)
        expect(File).to receive(:open).with('file').and_return(StringIO.new(content))

        response = klass.get_os_vars_from_rcfile(filename)
        expect(response).to eq({
          "OS_AUTH_URL"     => "http://127.0.0.1:5000",
          "OS_PASSWORD"     => "abc123",
          "OS_PROJECT_NAME" => "test",
          "OS_USERNAME"     => "test"})
      end
    end

    context 'with an empty file' do
      it 'provides an empty hash' do
        filename = 'file'
        expect(File).to receive(:exist?).with(filename).and_return(true)
        expect(File).to receive(:open).with(filename).and_return(StringIO.new(""))

        response = klass.get_os_vars_from_rcfile(filename)
        expect(response).to eq({})
      end
    end

    context 'with a nonexistent file' do
      it 'should get default rcfile when no environment or openrc file' do
        ENV.clear
        content = "export OS_USERNAME='user'\nexport OS_PASSWORD='secret'\nexport OS_PROJECT_NAME='project'\nexport OS_AUTH_URL='http://127.0.0.1:5000'"
        filename = '/root/openrc'

        expect(File).to receive(:exist?).with("#{ENV['HOME']}/openrc").and_return(false)
        expect(File).to receive(:exist?).with(filename).and_return(true)
        expect(File).to receive(:open).with(filename).and_return(StringIO.new(content))

        expect(klass.get_os_vars_from_rcfile("#{ENV['HOME']}/openrc")).to eq({
          'OS_USERNAME'     => 'user',
          'OS_PASSWORD'     => 'secret',
          'OS_PROJECT_NAME' => 'project',
          'OS_AUTH_URL'     => 'http://127.0.0.1:5000'
        })
      end
    end
  end

  before(:each) do
    class Puppet::Provider::Openstack::AuthTester
      @credentials =  Puppet::Provider::Openstack::CredentialsV3.new
    end
  end

  describe '#request' do
    context 'with no valid credentials' do
      it 'fails to authenticate' do
        expect { klass.request('project', 'list', ['--long']) }.to raise_error(Puppet::Error::OpenstackAuthInputError, "Insufficient credentials to authenticate")
        expect(klass.instance_variable_get(:@credentials).to_env).to eq({'OS_IDENTITY_API_VERSION' => '3'})
      end
    end

    context 'with user credentials in env' do
      it 'is successful' do
        expect(klass).to receive(:get_os_vars_from_env)
             .and_return({ 'OS_USERNAME'     => 'test',
                           'OS_PASSWORD'     => 'abc123',
                           'OS_PROJECT_NAME' => 'test',
                           'OS_AUTH_URL'     => 'http://127.0.0.1:5000',
                           'OS_NOT_VALID'    => 'notvalid' })
        expect(klass).to receive(:openstack)
             .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
             .and_return('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = klass.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq("Test tenant")
        expect(klass.instance_variable_get(:@credentials).to_env).to eq({
          'OS_USERNAME'             => 'test',
          'OS_PASSWORD'             => 'abc123',
          'OS_PROJECT_NAME'         => 'test',
          'OS_AUTH_URL'             => 'http://127.0.0.1:5000',
          'OS_IDENTITY_API_VERSION' => '3'
        })
      end
    end

    context 'with service token credentials in env' do
      it 'is successful' do
        expect(klass).to receive(:get_os_vars_from_env)
             .and_return({ 'OS_TOKEN'     => 'test',
                           'OS_ENDPOINT'  => 'http://127.0.0.1:5000',
                           'OS_NOT_VALID' => 'notvalid' })
        expect(klass).to receive(:openstack)
             .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
             .and_return('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = klass.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq("Test tenant")
        expect(klass.instance_variable_get(:@credentials).to_env).to eq({
          'OS_IDENTITY_API_VERSION' => '3',
          'OS_TOKEN'                => 'test',
          'OS_ENDPOINT'             => 'http://127.0.0.1:5000',
        })
      end
    end

    context 'with clouds.yaml file' do
      it 'is successful' do
        # return incomplete creds from env
        expect(klass).to receive(:get_os_vars_from_env)
             .and_return({ 'OS_USERNAME' => 'incompleteusername',
                           'OS_AUTH_URL' => 'incompleteauthurl' })
        expect(File).to receive(:exist?).with('/etc/openstack/puppet/clouds.yaml').and_return(true)
        expect(klass).to receive(:openstack)
             .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
             .and_return('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = provider.class.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq("Test tenant")
        expect(klass.instance_variable_get(:@credentials).to_env).to eq({
          'OS_IDENTITY_API_VERSION' => '3',
          'OS_CLOUD'                => 'project',
          'OS_CLIENT_CONFIG_FILE'   => '/etc/openstack/puppet/clouds.yaml',
        })
      end
    end

    context 'with a RC file containing user credentials' do
      it 'is successful' do
        # return incomplete creds from env
        expect(klass).to receive(:get_os_vars_from_env)
             .and_return({ 'OS_USERNAME' => 'incompleteusername',
                           'OS_AUTH_URL' => 'incompleteauthurl' })
        content = "export OS_USERNAME='test'\nexport OS_PASSWORD='abc123'\nexport OS_PROJECT_NAME='test'\nexport OS_AUTH_URL='http://127.0.0.1:5000'\nexport OS_NOT_VALID='notvalid'"
        expect(File).to receive(:exist?).with("/etc/openstack/puppet/clouds.yaml").and_return(false)
        expect(File).to receive(:exist?).with("/etc/openstack/puppet/admin-clouds.yaml").and_return(false)
        expect(File).to receive(:exist?).with("#{ENV['HOME']}/openrc").and_return(true)
        expect(File).to receive(:open).with("#{ENV['HOME']}/openrc").and_return(StringIO.new(content))
        expect(klass).to receive(:openstack)
             .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
             .and_return('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = provider.class.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq("Test tenant")
        expect(klass.instance_variable_get(:@credentials).to_env).to eq({
          'OS_USERNAME'             => 'test',
          'OS_PASSWORD'             => 'abc123',
          'OS_PROJECT_NAME'         => 'test',
          'OS_AUTH_URL'             => 'http://127.0.0.1:5000',
          'OS_IDENTITY_API_VERSION' => '3'
        })
      end
    end

    context 'with a RC file containing service token credentials' do
      it 'is successful' do
        # return incomplete creds from env
        expect(klass).to receive(:get_os_vars_from_env)
             .and_return({ 'OS_TOKEN' => 'incomplete' })
        content = "export OS_TOKEN='test'\nexport OS_ENDPOINT='abc123'\nexport OS_NOT_VALID='notvalid'\n"
        expect(File).to receive(:exist?).with("/etc/openstack/puppet/clouds.yaml").and_return(false)
        expect(File).to receive(:exist?).with("/etc/openstack/puppet/admin-clouds.yaml").and_return(false)
        expect(File).to receive(:exist?).with("#{ENV['HOME']}/openrc").and_return(true)
        expect(File).to receive(:open).with("#{ENV['HOME']}/openrc").and_return(StringIO.new(content))
        expect(klass).to receive(:openstack)
             .with('project', 'list', '--quiet', '--format', 'csv', ['--long'])
             .and_return('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = klass.request('project', 'list', ['--long'])
        expect(response.first[:description]).to eq("Test tenant")
        expect(klass.instance_variable_get(:@credentials).to_env).to eq({
          'OS_IDENTITY_API_VERSION' => '3',
          'OS_TOKEN'                => 'test',
          'OS_ENDPOINT'             => 'abc123',
        })
      end
    end
  end
end
