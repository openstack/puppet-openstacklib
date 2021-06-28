# == Class: openstacklib::params
#
# These parameters need to be accessed from several locations and
# should be considered to be constant
#
class openstacklib::params {

  include openstacklib::defaults
  $pyvers = $::openstacklib::defaults::pyvers

  $openstackclient_package_name = "python${pyvers}-openstackclient"

  case $::osfamily {
    'RedHat': {
      $open_iscsi_package_name = 'iscsi-initiator-utils'
    }
    'Debian': {
      $open_iscsi_package_name = 'open-iscsi'
    }
    default:{
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, \
module ${module_name} only support osfamily RedHat and Debian")
    }
  }
}
