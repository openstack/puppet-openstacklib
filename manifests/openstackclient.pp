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
class openstacklib::openstackclient(
  $package_ensure = 'present',
){

  $openstackclient_package_name = $::os_package_type ? {
    'debian' => 'python3-openstackclient',
    default  => 'python-openstackclient',
  }

  ensure_packages($openstackclient_package_name, {
    'ensure' => $package_ensure,
    'tag'    => 'openstack'
  })
}
