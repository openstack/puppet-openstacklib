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
  } elsif $::os['family'] == 'RedHat' {
    if Integer.new($::os['release']['major']) > 8 {
      $pyvers = '3'
      $pyver3 = '3.9'
    } elsif Integer.new($::os['release']['major']) == 8 {
      $pyvers = '3'
      $pyver3 = '3.6'
    } else {
      $pyvers = ''
      $pyver3 = '2.7'
    }
  } else {
    # TODO(tkajinam) This is left to keep the previous behavior but we should
    #                revisit this later.
    $pyvers = ''
    $pyver3 = '2.7'
  }
}
