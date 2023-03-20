require 'spec_helper'

describe 'os_url' do

  it 'refuses String' do
    is_expected.to run.with_params('foo').\
      and_raise_error(Puppet::ParseError, /Requires an hash/)
  end

  it 'refuses Array' do
    is_expected.to run.with_params(['foo']).\
      and_raise_error(Puppet::ParseError, /Requires an hash/)
  end

  it 'refuses without at least one argument' do
    is_expected.to run.with_params().\
      and_raise_error(Puppet::ParseError, /Wrong number of arguments/)
  end

  it 'refuses too many arguments' do
    is_expected.to run.with_params('foo', 'bar').\
      and_raise_error(Puppet::ParseError, /Wrong number of arguments/)
  end

  it 'refuses query params passed as String' do
    is_expected.to run.with_params({
        'query' => 'key=value'
      }).and_raise_error(Puppet::ParseError, /query should be a Hash/)
  end

  it 'fails if port is provided with missing host' do
    is_expected.to run.with_params({
        'port'  => '8080',
      }).and_raise_error(Puppet::ParseError, /host is required with port/)
  end

  context 'creates the correct connection URI' do

    it 'with all parameters' do
      is_expected.to run.with_params({
          'scheme'   => 'https',
          'host'     => '127.0.0.1',
          'port'     => '443',
          'path'     => '/test',
          'username' => 'guest',
          'password' => 's3cr3t',
          'query'    => { 'key1' => 'value1', 'key2' => 'value2' }
        }).and_return('https://guest:s3cr3t@127.0.0.1:443/test?key1=value1&key2=value2')
    end

    it 'without port' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'path'     => '/test',
          'username' => 'guest',
          'password' => 's3cr3t',
        }).and_return('http://guest:s3cr3t@127.0.0.1/test')
    end

    it 'without host and port' do
      is_expected.to run.with_params({
          'scheme'   => 'file',
          'path'     => '/test',
        }).and_return('file:///test')
    end

    it 'without username and password' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
        }).and_return('http://127.0.0.1')
    end

    it 'with username set to undef' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'username' => :undef,
        }).and_return('http://127.0.0.1')
    end

    it 'with username set to an empty string' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'username' => '',
        }).and_return('http://127.0.0.1')
    end

    it 'without password' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'username' => 'guest',
        }).and_return('http://guest@127.0.0.1')
    end

    it 'with password' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'password' => 's3cr3t',
        }).and_return('http://:s3cr3t@127.0.0.1')
    end

    it 'with password set to undef' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'username' => 'guest',
          'password' => :undef,
        }).and_return('http://guest@127.0.0.1')
    end

    it 'with password set to an empty string' do
      is_expected.to run.with_params({
          'host'     => '127.0.0.1',
          'username' => 'guest',
          'password' => '',
        }).and_return('http://guest@127.0.0.1')
    end
  end
end
