# This function builds a os_transport_url string from a hash of parameters.
#
# Valid hash parameteres:
#  * transport - (string) type of transport, 'rabbit' or 'amqp'
#  * host - (string) single host
#  * hosts - (array) array of hosts to use
#  * port - (string | integer) port to connect to
#  * username - (string) connection username
#  * password - (string) connection password
#  * virtual_host - (string) virtual host to connect to
#  * ssl - (string) is the connection ssl or not ('1' or '0'). overrides the ssl
#    key in the query parameter
#  * query - (hash) hash of key,value pairs used to create a query string for
#    the transport_url.
#
# Only 'transport' and either 'host' or 'hosts' are required keys for the
# parameters hash.
#
# The url format that will be generated:
# transport://user:pass@host:port[,userN:passN@hostN:portN]/virtual_host?query
#
# NOTE: ipv6 addresses will automatically be bracketed for the URI using the
# normalize_ip_for_uri function.
#
# Single Host Example:
# os_transport_url({
#   'transport'    => 'rabbit',
#   'host'         => '1.1.1.1',
#   'port'         => '5672',
#   'username'     => 'username',
#   'password'     => 'password',
#   'virtual_host' => 'virtual_host',
#   'ssl'          => '1',
#   'query'        => { 'key' => 'value' },
# })
#
# Generates:
# rabbit://username:password@1.1.1.1:5672/virtual_host?key=value&ssl=1
#
# Multiple Hosts Example:
# os_transport_url({
#   'transport'    => 'rabbit',
#   'hosts'        => [ '1.1.1.1', '2.2.2.2' ],
#   'port'         => '5672',
#   'username'     => 'username',
#   'password'     => 'password',
#   'virtual_host' => 'virtual_host',
#   'query'        => { 'key' => 'value' },
# })
#
# Generates:
# rabbit://username:password@1.1.1.1:5672,username:password@2.2.2.2:5672/virtual_host?key=value
Puppet::Functions.create_function(:os_transport_url) do
  # TODO(tobias-urdin): Rework and remove this.
  # Taken straight from stdlib v5.1.0 module.
  def _str2bool(string)
    if !!string == string
      return string
    end
    unless string.is_a?(String)
      raise(Puppet::ParseError, 'str2bool(): Requires string to work with')
    end
    result = case string
             when %r{^$}, '' then false # Empty string will be false ...
             when %r{^(1|t|y|true|yes)$}i  then true
             when %r{^(0|f|n|false|no)$}i  then false
             when %r{^(undef|undefined)$} then false # This is not likely to happen ...
             else
               raise(Puppet::ParseError, 'os_transport_url _str2bool(): Unknown type of boolean given')
             end
    return result
  end

  # TODO(tobias-urdin): Rework and remove this.
  # Taken straight from stdlib v5.1.0 module.
  def _bool2num(val)
    value = _str2bool(val)
    result = value ? 1 : 0
    return result
  end

  def os_transport_url(*args)
    require 'uri'

    unless args.size == 1
      raise(ArgumentError, 'os_transport_url(): Wrong number of arguments')
    end

    v_raw = args[0]
    klass = v_raw.class

    unless klass == Hash
      raise(Puppet::ParseError, "os_transport_url(): Requires an hash, got #{klass}")
    end

    v = {}
    # type checking for the parameter hash
    v_raw.keys.each do |key|
      if key == 'port'
        v[key] = v_raw[key].to_s
      else
        v[key] = v_raw[key]
      end
      klass = (key == 'hosts') ? Array : String
      klass = (key == 'query') ? Hash : klass
      unless (v[key].class == klass) or (v[key] == :undef)
        raise(Puppet::ParseError, "os_transport_url(): #{key} should be a #{klass}")
      end
    end

    # defaults
    parts = {
      :transport => 'rabbit',
      :hostinfo  => 'localhost',
      :path      => '/',
    }

    unless v.include?('transport')
      raise(Puppet::ParseError, 'os_transport_url(): transport is required')
    end

    unless v.include?('host') or v.include?('hosts')
      raise(Puppet::ParseError, 'os_transport_url(): host or hosts is required')
    end

    if v.include?('host') and v.include?('hosts')
      raise(Puppet::ParseError, 'os_transport_url(): cannot use both host and hosts.')
    end

    parts[:transport] = v['transport']

    if v.include?('username') and (v['username'] != :undef) and (v['username'].to_s != '')
      parts[:userinfo] = URI.escape(v['username'])
      if v.include?('password') and (v['password'] != :undef) and (v['password'].to_s != '')
        parts[:userinfo] += ":#{URI.escape(v['password'])}"
      end
    end

    if v.include?('host')
      host = call_function('normalize_ip_for_uri', v['host'])
      host += ":#{v['port'].to_s}" if v.include?('port')
      if parts.include?(:userinfo)
        parts[:hostinfo] = "#{parts[:userinfo]}@#{host}"
      else
        parts[:hostinfo] = "#{host}"
      end
    end

    if v.include?('hosts')
      hosts = call_function('normalize_ip_for_uri', v['hosts'])
      # normalize_ip_for_uri may return a string, so check that we still have an
      # array
      hosts = [hosts] if hosts.kind_of?(String)
      hosts = hosts.map{ |h| "#{h}:#{v['port'].to_s}" } if v.include?('port')
      if parts.include?(:userinfo)
        parts[:hostinfo] = hosts.map { |h| "#{parts[:userinfo]}@#{h}" }.join(',')
      else
        parts[:hostinfo] = hosts.join(',')
      end
    end

    parts[:path] = "/#{v['virtual_host']}" if v.include?('virtual_host')

    query = {}
    if v.include?('query')
      query.merge!(v['query'])
    end

    # support previous ssl option on the function. Setting ssl will
    # override ssl if passed in via the query parameters
    if v.include?('ssl')
      # ssl can be passed in as a query paramter but should be 0/1. See
      # http://docs.celeryproject.org/projects/kombu/en/latest/userguide/connections.html#urls
      # so we rely on _str2bool and _bool2num to ensure it's in the
      # format
      # TODO(tobias-urdin): Rework this to using proper data types and not the
      # legacy puppet functions that is copied into this function statement.
      # We need to do this right now because it fails testing if we call the
      # str2bool or bool2num legacy functions using call_function.
      ssl_str = _str2bool(v['ssl'])
      ssl_val = _bool2num(v['ssl'])

      query.merge!({ 'ssl' => ssl_val })
    end

    parts[:query] = query.map{ |k,val| "#{k}=#{val}" }.join('&') if ! query.empty?

    url_parts = []
    url_parts << parts[:transport]
    url_parts << '://'
    url_parts << parts[:hostinfo]
    url_parts << parts[:path]
    url_parts << '?' << parts[:query] if parts.include?(:query)
    url_parts.join()
  end
end
