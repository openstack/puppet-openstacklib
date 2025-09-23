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
#    Defaults to $openstacklib::params::openstackclient_package_name
#
class openstacklib::openstackclient (
  String[1] $package_name                 = $openstacklib::params::openstackclient_package_name,
  Stdlib::Ensure::Package $package_ensure = 'present'
) inherits openstacklib::params {
  stdlib::ensure_packages($package_name, {
    'ensure' => $package_ensure,
    'tag'    => ['openstack', 'openstackclient']
  })
}
