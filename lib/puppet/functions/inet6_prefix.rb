# Add inet6 prefix if the argument is an IPv6 address.
#
# This is useful for services relying on python-memcached which require
# the inet6:[<ip_address]:<port> format.
#
# Returns the argument untouched otherwise.
Puppet::Functions.create_function(:inet6_prefix) do
  def inet6_prefix(*args)
    require 'ipaddr'

    result = []
    args = args[0] if args[0].kind_of?(Array)
    args = [args] unless args.kind_of?(Array)
    args.each do |ip|
      begin
        unless ip.match(/^inet6:.+/)
          ip_parts = ip.split(/\s|\[|\]/).reject { |c| c.empty? }
          if IPAddr.new(ip_parts[0]).ipv6?
            Puppet.debug("#{ip} is changed to inet6:[#{ip}]")
            ip = "inet6:[#{ip_parts.shift}]#{ip_parts.join}"
          end
        end
      rescue ArgumentError, NoMethodError => e
        # ignore it
      end
      result << ip
    end
    return result[0] if args.size == 1
    result
  end
end
