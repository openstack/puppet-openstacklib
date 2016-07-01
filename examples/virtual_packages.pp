Exec { logoutput => 'on_failure' }

include ::openstacklib::defaults

if $::osfamily == 'RedHat' {
  # Virtual package name, present in @base.
  package { 'perl(Net::HTTP)':
    ensure => present,
    tag    => 'openstack',
  }
}
