# == Class: openstacklib::params
#
# These parameters need to be accessed from several locations and
# should be considered to be constant
#
class openstacklib::params {
  include openstacklib::defaults

  $openstackclient_package_name = 'python3-openstackclient'

  case $facts['os']['family'] {
    'RedHat': {
      $open_iscsi_package_name = 'iscsi-initiator-utils'
    }
    'Debian': {
      $open_iscsi_package_name = 'open-iscsi'
    }
    default:{
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
