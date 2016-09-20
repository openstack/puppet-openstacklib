require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:normalize_ip_for_uri,
              :type => :rvalue,
              :doc => <<-EOD
    Add brackets if the argument is an IPv6 address.
    Returns the argument untouched otherwise.
    CAUTION: this code "fails" when the user is passing
    an IPv6 address with the port in it without the
    brackets: 2001::1:8080, to specify address 2001::1
    and port 8080.  This code will change it to
    [2001::1:8080] as it's a valid ip address.  This
    shouldn't be an issue in most cases.
    If an array is given, each member will be normalized to
    a valid IPv6 address with brackets when needed.
    EOD
    ) do |args|
    result = []
    args = args[0] if args[0].kind_of?(Array)
    args.each do |ip|
      begin
        if IPAddr.new(ip).ipv6?
          unless ip.match(/\[.+\]/)
            Puppet.debug("IP #{ip} is changed to [#{ip}]")
            ip = "[#{ip}]"
          end
        end
      rescue ArgumentError
        # ignore it
      end
      result << ip
    end
    return result[0] if args.size == 1
    result
  end
end
