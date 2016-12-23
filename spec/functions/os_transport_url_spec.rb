require 'spec_helper'

describe 'os_transport_url' do

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
      and_raise_error(ArgumentError, /Wrong number of arguments/)
  end

  it 'refuses too many arguments' do
    is_expected.to run.with_params('foo', 'bar').\
      and_raise_error(ArgumentError, /Wrong number of arguments/)
  end

  it 'refuses hosts params passed as String' do
    is_expected.to run.with_params({
        'transport'=> 'rabbit',
        'hosts'    => '127.0.0.1',
      }).and_raise_error(Puppet::ParseError, /hosts should be a Array/)
  end

  it 'fails if missing host' do
    is_expected.to run.with_params({
        'transport'=> 'rabbit',
      }).and_raise_error(Puppet::ParseError, /host or hosts is required/)
  end

  context 'creates the correct transport URI' do

    it 'with a single host array for hosts' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'hosts'        =>  [ '127.0.0.1' ],
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => 's3cr3t',
          'virtual_host' => 'virt',
          'ssl'          => '1',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest:s3cr3t@127.0.0.1:5672/virt?read_timeout=60&ssl=1')
    end

    it 'with all params for a single host' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => 's3cr3t',
          'virtual_host' => 'virt',
          'ssl'          => '1',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest:s3cr3t@127.0.0.1:5672/virt?read_timeout=60&ssl=1')
    end

    it 'with only required params for a single host' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
        }).and_return('rabbit://127.0.0.1/')
    end

    it 'with a single ipv6 address' do
      is_expected.to run.with_params({
          'transport' => 'rabbit',
          'host'      => 'fe80::ca5b:76ff:fe4b:be3b',
          'port'      => '5672'
        }).and_return('rabbit://[fe80::ca5b:76ff:fe4b:be3b]:5672/')
    end

    it 'with all params with multiple hosts' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'hosts'        => ['1.1.1.1', '2.2.2.2'],
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => 's3cr3t',
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
      }).and_return('rabbit://guest:s3cr3t@1.1.1.1:5672,guest:s3cr3t@2.2.2.2:5672/virt?read_timeout=60')
    end

    it 'with only required params for multiple hosts' do
      is_expected.to run.with_params({
          'transport' => 'rabbit',
          'hosts'     => [ '1.1.1.1', '2.2.2.2' ],
          'port'      => '5672',
          'username'  => 'guest',
          'password'  => 's3cr3t',
        }).and_return('rabbit://guest:s3cr3t@1.1.1.1:5672,guest:s3cr3t@2.2.2.2:5672/')
    end

    it 'with multiple ipv6 hosts' do
      is_expected.to run.with_params({
          'transport' => 'rabbit',
          'hosts'     => [ 'fe80::ca5b:76ff:fe4b:be3b', 'fe80::ca5b:76ff:fe4b:be3c' ],
          'port'      => '5672',
          'username'  => 'guest',
          'password'  => 's3cr3t',
        }).and_return('rabbit://guest:s3cr3t@[fe80::ca5b:76ff:fe4b:be3b]:5672,guest:s3cr3t@[fe80::ca5b:76ff:fe4b:be3c]:5672/')
    end

    it 'with a mix of ipv4 and ipv6 hosts' do
      is_expected.to run.with_params({
          'transport' => 'rabbit',
          'hosts'     => [ 'fe80::ca5b:76ff:fe4b:be3b', '1.1.1.1' ],
          'port'      => '5672',
          'username'  => 'guest',
          'password'  => 's3cr3t',
      }).and_return('rabbit://guest:s3cr3t@[fe80::ca5b:76ff:fe4b:be3b]:5672,guest:s3cr3t@1.1.1.1:5672/')
    end

    it 'without port' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'username'     => 'guest',
          'password'     => 's3cr3t',
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest:s3cr3t@127.0.0.1/virt?read_timeout=60')
    end

    it 'without port and query' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'username'     => 'guest',
          'password'     => 's3cr3t',
          'virtual_host' => 'virt',
        }).and_return('rabbit://guest:s3cr3t@127.0.0.1/virt')
    end

    it 'without username and password' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://127.0.0.1:5672/virt?read_timeout=60')
    end

    it 'with username set to undef' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => :undef,
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://127.0.0.1:5672/virt?read_timeout=60')
    end

    it 'with username set to an empty string' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => '',
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://127.0.0.1:5672/virt?read_timeout=60')
    end

    it 'without password' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60')
    end

    it 'with password set to undef' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => :undef,
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60')
    end

    it 'with password set to an empty string' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => '',
          'virtual_host' => 'virt',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60')
    end

    it 'with ssl overrides ssl in quert hash' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => '',
          'virtual_host' => 'virt',
          'ssl'          => '1',
          'query'        => { 'read_timeout' => '60' , 'ssl' => '0'},
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60&ssl=1')
    end

    it 'with ssl as boolean string' do
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => '',
          'virtual_host' => 'virt',
          'ssl'          => 'true',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60&ssl=1')
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => '',
          'virtual_host' => 'virt',
          'ssl'          => 'false',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60&ssl=0')
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => '',
          'virtual_host' => 'virt',
          'ssl'          => 'True',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60&ssl=1')
      is_expected.to run.with_params({
          'transport'    => 'rabbit',
          'host'         => '127.0.0.1',
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => '',
          'virtual_host' => 'virt',
          'ssl'          => 'False',
          'query'        => { 'read_timeout' => '60' },
        }).and_return('rabbit://guest@127.0.0.1:5672/virt?read_timeout=60&ssl=0')
    end

    it 'with alternative transport and single host array for hosts' do
      is_expected.to run.with_params({
          'transport'    => 'amqp',
          'hosts'        =>  [ '127.0.0.1' ],
          'port'         => '5672',
          'username'     => 'guest',
          'password'     => 's3cr3t',
        }).and_return('amqp://guest:s3cr3t@127.0.0.1:5672/')
    end

  end
end
