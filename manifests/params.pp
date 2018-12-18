# == Class: openstacklib::params
#
# These parameters need to be accessed from several locations and
# should be considered to be constant
#
class openstacklib::params {

  if ($::os_package_type == 'debian') or ($::os['name'] == 'Fedora') or
    ($::os['family'] == 'RedHat' and Integer.new($::os['release']['major']) > 7) {
    $pyvers = '3'
  } else {
    $pyvers = ''
  }
  $openstackclient_package_name = "python${pyvers}-openstackclient"
}
