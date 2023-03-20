Puppet::Functions.create_function(:os_url) do
  def os_url(*args)
    require 'erb'

    if (args.size != 1) then
      raise(Puppet::ParseError, "os_url(): Wrong number of arguments " +
        "given (#{args.size} for 1)")
    end

    v = args[0]
    klass = v.class

    unless klass == Hash
      raise(Puppet::ParseError, "os_url(): Requires an hash, got #{klass}")
    end

    v.keys.each do |key|
      klass = (key == 'query') ? Hash : String
      unless (v[key].class == klass) or (v[key] == :undef)
        raise(Puppet::ParseError, "os_url(): #{key} should be a #{klass}")
      end
    end

    parts = {}

    if v.include?('scheme')
      parts[:scheme] = v['scheme']
    else
      parts[:scheme] = 'http'
    end

    if v.include?('host')
      parts[:host] = v['host']
    end

    if v.include?('port')
      if v.include?('host')
        parts[:port] = v['port'].to_i
      else
        raise(Puppet::ParseError, 'os_url(): host is required with port')
      end
    end

    if v.include?('path')
      parts[:path] = v['path']
    end

    userinfo = ''
    if v.include?('username') and (v['username'] != :undef) and (v['username'].to_s != '')
      userinfo = ERB::Util.url_encode(v['username'])
    end
    if v.include?('password') and (v['password'] != :undef) and (v['password'].to_s != '')
      userinfo += ":#{ERB::Util.url_encode(v['password'])}"
    end

    if userinfo != ''
      parts[:userinfo] = userinfo
    end

    if v.include?('query') and ! v['query'].empty?
      parts[:query] = v['query'].map{ |k,v| "#{k}=#{v}" }.join('&')
    end

    URI::Generic.build(parts).to_s
  end
end
