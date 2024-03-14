# == Class: openstacklib::iscsid
#
# Installs and configures the iscsid daemon
#
# == Parameters
#
#  [*enabled*]
#    (optional) Should the service be enabled.
#    Defaults to true.
#
#  [*manage_service*]
#    (optional)  Whether the service should be managed by Puppet.
#    Defaults to true.
#
#  [*package_ensure*]
#    (optional) ensure state for package.
#    Defaults to 'present'
#
class openstacklib::iscsid(
  Boolean $enabled        = true,
  Boolean $manage_service = true,
  $package_ensure         = 'present'
) {

  include openstacklib::params

  package { 'open-iscsi':
    ensure => $package_ensure,
    name   => $::openstacklib::params::open_iscsi_package_name,
    tag    => 'openstack',
  }

  # In CentOS9/RHEL9 initiatorname.iscsi is not created automatically
  # so should be created
  exec { 'create-initiatorname-file':
    command => 'echo "InitiatorName=`/usr/sbin/iscsi-iname`" > /etc/iscsi/initiatorname.iscsi',
    path    => ['/usr/bin','/usr/sbin','/bin','/usr/bin'],
    creates => '/etc/iscsi/initiatorname.iscsi',
    require => Package['open-iscsi'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    # iscsid service is started automatically when iscsiadm command is
    # executed but there is no harm even if the service is already started.
    service { 'iscsid':
      ensure => $service_ensure,
      enable => $enabled,
    }
    Package['open-iscsi'] ~> Service['iscsid']
    Exec['create-initiatorname-file'] ~> Service['iscsid']
  }
}
