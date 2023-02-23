# == Class: openstacklib::defaults
#
# Default configuration for all openstack-puppet module.
#
# This file is loaded in the params.pp of each class.
#
class openstacklib::defaults {
  case $::osfamily {
    'RedHat': {
      $pyver3 = '3.9'
    }
    'Debian': {
      $pyver3 = '3'
    }
    default:{
      fail("Unsupported osfamily: ${::osfamily}")
    }
  }
}
