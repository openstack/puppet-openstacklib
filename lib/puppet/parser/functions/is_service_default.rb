#
# is_service_default.rb
#
# This function can be used to check if a variable is set to the default value
# of '<SERVICE DEFAULT>'
#
# For reference:
# http://lists.openstack.org/pipermail/openstack-dev/2015-July/069823.html
# https://github.com/openstack/puppet-openstacklib/commit/3b85306d042292713d0fd89fa508e0a0fbf99671
#
module Puppet::Parser::Functions
  newfunction(:is_service_default, :type => :rvalue, :doc => <<-EOS
Returns true if the variable passed to this function is '<SERVICE DEFAULT>'
  EOS
  ) do |arguments|
    raise(Puppet::ParseError, "is_service_default(): Wrong number of arguments" +
          "given (#{arguments.size} for 1)") if arguments.size != 1

    value = arguments[0]

    unless value.is_a?(String)
      return false
    end

    return (value == '<SERVICE DEFAULT>')
  end
end
