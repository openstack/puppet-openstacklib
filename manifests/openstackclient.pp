# == Class: openstacklib::openstackclient
#
# Installs the openstackclient
#
# == Parameters
#
#  [*package_ensure*]
#    (Optional) Ensure state of the openstackclient package.
#    Defaults to 'present'
#
#  [*package_name*]
#    (Optional) The name of the package to install
#    Defaults to $::openstacklib::params::openstackclient_package_name
#
class openstacklib::openstackclient(
  $package_name   = $::openstacklib::params::openstackclient_package_name,
  $package_ensure = 'present',
) inherits ::openstacklib::params {

  ensure_packages($package_name, {
    'ensure' => $package_ensure,
    'tag'    => 'openstack'
  })
}
