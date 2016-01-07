require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:normalize_ip_for_uri,
              :type => :rvalue,
              :arity => 1,
              :doc => <<-EOD
    Add brackets if the argument is an IPv6 address.
    Returns the argument untouched otherwise.
    CAUTION: this code "fails" when the user is passing
    an IPv6 address with the port in it without the
    brackets: 2001::1:8080, to specify address 2001::1
    and port 8080.  This code will change it to
    [2001::1:8080] as it's a valid ip address.  This
    shouldn't be an issue in most cases.
    EOD
  ) do |args|
    ip = args[0]
    begin
      if IPAddr.new(ip).ipv6?
        unless ip.match(/\[.+\]/)
          Puppet.debug("IP #{ip} is changed to [#{ip}]")
          ip = "[#{ip}]"
        end
      end
    rescue ArgumentError => e
      # ignore it
    end
    return ip
  end
end
