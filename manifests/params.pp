# == Class: openstacklib::params
#
# These parameters need to be accessed from several locations and
# should be considered to be constant
#
class openstacklib::params {

  $openstackclient_package_name = $::os_package_type ? {
    'debian' => 'python3-openstackclient',
    default  => 'python-openstackclient',
  }
}
