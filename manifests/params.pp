# == Class: openstacklib::params
#
# These parameters need to be accessed from several locations and
# should be considered to be constant
#
class openstacklib::params {

  include openstacklib::defaults
  $pyvers = $::openstacklib::defaults::pyvers

  $openstackclient_package_name = "python${pyvers}-openstackclient"
}
