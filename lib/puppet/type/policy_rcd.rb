Puppet::Type.newtype(:policy_rcd) do
  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newproperty(:service) do
    defaultto { @resource[:name] }
    newvalues(/\S+/)
  end

  newproperty(:set_code) do
    defaultto('101')
    validate do |value|
      # validate codes according to https://people.debian.org/~hmh/invokerc.d-policyrc.d-specification.txt
      allowed_codes = [ '0', '1', '100', '101', '102', '103', '104', '105', '106' ]
      raise ArgumentError, 'Unknown exit status code is set' unless allowed_codes.include?(value)
    end
  end
end
