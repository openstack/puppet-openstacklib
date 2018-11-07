# This function can be used to check if a variable is set to the default value
# of '<SERVICE DEFAULT>'
#
# For reference:
# http://lists.openstack.org/pipermail/openstack-dev/2015-July/069823.html
# https://github.com/openstack/puppet-openstacklib/commit/3b85306d042292713d0fd89fa508e0a0fbf99671
Puppet::Functions.create_function(:is_service_default) do
  def is_service_default(*args)
    raise(Puppet::ParseError, "is_service_default(): Wrong number of arguments" +
          "given (#{args.size} for 1)") if args.size != 1

    value = args[0]

    unless value.is_a?(String)
      return false
    end

    return (value == '<SERVICE DEFAULT>')
  end
end
