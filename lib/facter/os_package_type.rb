#
# We need this to be able to make decision of what style of package we are
# working with: Debian style package (for example, it uses a nova-consoleproxy
# package and not nova-novncproxy, or it has a openstack-dashboard-apache,
# etc.), or just the Ubuntu style package.
#
# This is needed, because in some cases, we are using the Debian style packages
# but running under Ubuntu. For example, that's the case when running with MOS
# over Ubuntu. For this case, a manual override is provided, in the form of a
# /etc/facter/facts.d/os_package_type.txt containing:
# os_package_type=debian
#
# In all other cases, we can consider that we're using vanilia (ie: unmodified)
# distribution packages, and we can set $::os_package_type depending on the
# value of $::operatingsystem.
#
# Having the below snipets helps simplifying checks within individual project
# manifests, so that we can just reuse $::os_package_type directly without
# having to also check if it contains a value, then check for the content of
# $::operatingsystem (ie: what's below factors the check once and for all).
Facter.add('os_package_type') do
  setcode do
    case Facter.value(:osfamily)
    when 'Debian'
      if Facter.value(:operatingsystem) == 'Debian' then
        'debian'
      else
        'ubuntu'
      end
    when 'RedHat'
      'rpm'
    when 'Solaris'
      'solaris'
    else
      'unknown'
    end
  end
end
