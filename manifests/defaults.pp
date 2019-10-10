# == Class: openstacklib::defaults
#
# Default configuration for all openstack-puppet module.
#
# This file is loaded in the params.pp of each class.
#
class openstacklib::defaults {

  # TODO(tobias-urdin): Remove this in the V release when
  # we officially remove the support.
  if versioncmp($::puppetversion, '6.0.0') < 0 {
    warning('OpenStack modules support for Puppet 5 is deprecated \
and will be officially unsupported in the V release')
  }

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
