# == Class: openstacklib::defaults
#
# Default configuration for all openstack-puppet module.
#
# This file is loaded in the params.pp of each class.
#
class openstacklib::defaults {
  # Ensure all package resources have virtual package enable.
  if versioncmp($::puppetversion, '4.0.0') < 0 and versioncmp($::puppetversion, '3.6.1') >= 0 {
    Package<| tag == 'openstack' |> {
      allow_virtual => true,
    }
  }
}
