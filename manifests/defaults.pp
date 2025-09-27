# == Class: openstacklib::defaults
#
# Default configuration for all openstack-puppet module.
#
# This file is loaded in the params.pp of each class.
#
class openstacklib::defaults {
  case $facts['os']['family'] {
    'RedHat': {
      $pyver3 = $facts['os']['release']['major'] ? {
        '10'    => '3.12',
        default => '3.9',
      }
    }
    'Debian': {
      $pyver3 = '3'
    }
    default:{
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
