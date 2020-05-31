# == Class: openstacklib::defaults
#
# Default configuration for all openstack-puppet module.
#
# This file is loaded in the params.pp of each class.
#
class openstacklib::defaults {

  if ($::os['family'] == 'Debian') {
    $pyvers = '3'
    $pyver3 = '3'
  } elsif ($::os['name'] == 'Fedora') or
          ($::os['family'] == 'RedHat' and Integer.new($::os['release']['major']) > 7) {
    $pyvers = '3'
    $pyver3 = '3.6'
  } else {
    $pyvers = ''
    $pyver3 = '2.7'
  }
}
