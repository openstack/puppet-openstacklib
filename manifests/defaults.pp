# == Class: openstacklib::defaults
#
# Default configuration for all openstack-puppet module.
#
# This file is loaded in the params.pp of each class.
#
class openstacklib::defaults {

  # TODO(tobias-urdin): Remove this in the T release when we remove
  # all Puppet 4 related code.
  if versioncmp($::puppetversion, '5.0.0') < 0 {
    warning('OpenStack modules support for Puppet 4 is deprecated \
and will be officially unsupported in the T release')
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
