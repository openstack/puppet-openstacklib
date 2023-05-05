# == Define: openstacklib::policies
#
# This resource is an helper to call the policy definition
#
# == Parameters:
#
# [*policy_path*]
#   (Optional) Path to the policy file. This should be an asbolute path.
#   Defaults to $name
#
# [*policies*]
#   (Optional) Set of policies to configure
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
#   (Optional) Format for file contents. Valid values
#   are 'json' or 'yaml'.
#   Defaults to 'json'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified policy rules in the policy
#   file.
#   Defaults to false.
#
define openstacklib::policy (
  $policy_path  = $name,
  $policies     = {},
  $file_mode    = '0640',
  $file_user    = undef,
  $file_group   = undef,
  $file_format  = 'json',
  $purge_config = false,
) {
  validate_legacy(Hash, 'validate_hash', $policies)
  validate_legacy(Stdlib::Compat::Absolute_path, 'validate_absolute_path', $policy_path)
  validate_legacy(Boolean, 'validate_bool', $purge_config)

  if empty($policies) {
    create_resources('openstacklib::policy::default', { $policy_path => {
      file_mode    => $file_mode,
      file_user    => $file_user,
      file_group   => $file_group,
      file_format  => $file_format,
      purge_config => $purge_config,
    }})
  } else {
    $policy_defaults = {
      file_path    => $policy_path,
      file_mode    => $file_mode,
      file_user    => $file_user,
      file_group   => $file_group,
      file_format  => $file_format,
      purge_config => $purge_config
    }

    create_resources('openstacklib::policy::base', $policies, $policy_defaults)
  }
}
