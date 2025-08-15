# == Class: openstacklib::clouds
#
# Generates clouds.yaml for openstack CLI
#
# == Parameters
#
# [*username*]
#   (Required) The name of the keystone user.
#
# [*password*]
#   (Required) Password of the keystone user.
#
# [*auth_url*]
#   (Required) The URL to use for authentication.
#
# [*path*]
#   (Optional) Path to the clouds.yaml file.
#   Defaults to $name
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username.
#   Defaults to 'Default'
#
# [*project_name*]
#   (Optional) The name of the keystone project.
#   Defaults to undef
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name.
#   Defaults to 'Default'
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to undef
#
# [*interface*]
#   (Optional) Determine the endpoint to be used.
#   Defaults to undef
#
# [*region_name*]
#   (Optional) The region in which the service can be found.
#   Defaults to undef
#
# [*api_versions*]
#   (Optional) Hash of service type and version to determine API version
#   for that service to use.
#   Example: { 'identity' => '3', 'compute' => '2.latest' }
#   Defaults to {}
#
# [*file_user*]
#   (Optional) User that owns the clouds.yaml file.
#   Defaults to 'root'.
#
# [*file_group*]
#   (Optional) Group that owns the clouds.yaml file.
#   Defaults to 'root'.
#
define openstacklib::clouds (
  String[1] $username,
  String[1] $password,
  Stdlib::HTTPUrl $auth_url,
  Stdlib::Absolutepath $path                               = $name,
  String[1] $user_domain_name                              = 'Default',
  Optional[String[1]] $project_name                        = undef,
  String[1] $project_domain_name                           = 'Default',
  Optional[String[1]] $system_scope                        = undef,
  Optional[Enum['public', 'internal', 'admin']] $interface = undef,
  Optional[String[1]] $region_name                         = undef,
  Hash $api_versions                                       = {},
  String $file_user                                        = 'root',
  String $file_group                                       = 'root',
) {
  if !$project_name and !$system_scope {
    fail('One of project_name and system_scope should be set')
  }

  file { $path:
    ensure    => file,
    mode      => '0600',
    owner     => $file_user,
    group     => $file_group,
    content   => template('openstacklib/clouds.yaml.erb'),
    show_diff => false,
  }
}
