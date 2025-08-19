# == Definition: openstacklib::policy::default
#
# Create a default (empty) policy fie for an OpenStack service
#
# == Parameters:
#
# [*file_path*]
#   (Optional) Path to the policy file
#   Defaults to $name
#
# [*file_mode*]
#   (Optional) Permission mode for the policy file
#   Defaults to '0640'
#
# [*file_user*]
#   (Optional) User for the policy file
#   Defaults to undef
#
# [*file_group*]
#   (Optional) Group for the policy file
#   Defaults to undef
#
# [*file_format*]
#   (Optional) Format for file contents. Valid value is 'yaml'.
#   Defaults to 'yaml'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified policy rules in the policy
#   file.
#   Defaults to false.
#
define openstacklib::policy::default (
  Stdlib::Absolutepath $file_path   = $name,
  Stdlib::Filemode $file_mode       = '0640',
  $file_user                        = undef,
  $file_group                       = undef,
  Enum['yaml'] $file_format         = 'yaml',
  Boolean $purge_config             = false,
) {
  ensure_resource('file', $file_path, {
    mode    => $file_mode,
    owner   => $file_user,
    group   => $file_group,
    replace => $purge_config,
    content => ''
  })
}
