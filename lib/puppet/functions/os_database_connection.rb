Puppet::Functions.create_function(:os_database_connection) do
  def os_database_connection(*args)
    require 'uri'

    if (args.size != 1) then
      raise(Puppet::ParseError, "os_database_connection(): Wrong number of arguments " +
        "given (#{args.size} for 1)")
    end

    v = args[0]
    klass = v.class

    unless klass == Hash
      raise(Puppet::ParseError, "os_database_connection(): Requires an hash, got #{klass}")
    end

    v.keys.each do |key|
      klass = (key == 'extra') ? Hash : String
      unless (v[key].class == klass) or (v[key] == :undef)
        raise(Puppet::ParseError, "os_database_connection(): #{key} should be a #{klass}")
      end
    end

    parts = {}

    unless v.include?('dialect')
      raise(Puppet::ParseError, 'os_database_connection(): dialect is required')
    end

    if v.include?('host')
      parts[:host] = v['host']
    end

    unless v.include?('database')
      raise(Puppet::ParseError, 'os_database_connection(): database is required')
    end

    if v.include?('port')
      if v.include?('host')
        parts[:port] = v['port'].to_i
      else
        raise(Puppet::ParseError, 'os_database_connection(): host is required with port')
      end
    end

    if v.include?('username') and (v['username'] != :undef) and (v['username'].to_s != '')
      parts[:userinfo] = URI.escape(v['username'])
      if v.include?('password') and (v['password'] != :undef) and (v['password'].to_s != '')
        parts[:userinfo] += ":#{URI.escape(v['password'])}"
      end
    end

    # support previous charset option on the function. Setting charset will
    # override charset if passed in via the extra parameters
    extra = {}
    if v.include?('extra')
      extra.merge!(v['extra'])
    end
    if v.include?('charset')
      extra.merge!({ 'charset' => v['charset'] })
    end

    parts[:query] = extra.map{ |k,v| "#{k}=#{v}" }.join('&') if ! extra.empty?

    parts[:scheme] = v['dialect']

    if v.include?('host')
      parts[:path] = "/#{v['database']}"
    else
      parts[:path] = "///#{v['database']}"
    end

    URI::Generic.build(parts).to_s
  end
end
