# == Definition: openstacklib::policy::default
#
# Create a default (empty) policy fie for an OpenStack service
#
# == Parameters:
#
# [*file_path*]
#   (Optional) Path to the policy.json file
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
#   (Optional) Format for file contents. Valid values
#   are 'json' or 'yaml'.
#   Defaults to 'json'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified policy rules in the policy
#   file.
#   Defaults to false.
#
define openstacklib::policy::default (
  $file_path    = $name,
  $file_mode    = '0640',
  $file_user    = undef,
  $file_group   = undef,
  $file_format  = 'json',
  $purge_config = false,
) {

  case $file_format {
    'json': {
      warning('Json format is deprecated and will be removed in a future release')
      $content = '{}'
    }
    'yaml': {
      if stdlib::extname($file_path) == '.json' {
        # NOTE(tkajinam): It is likely that user is not aware of migration from
        #                 policy.json to policy.yaml
        fail("file_path: ${file_path} should be a yaml file instead of a json file")
      }
      $content = ''
    }
    default: {
      fail("${file_format} is an unsupported policy file format. Choose 'json' or 'yaml'.")
    }
  }

  ensure_resource('file', $file_path, {
    mode    => $file_mode,
    owner   => $file_user,
    group   => $file_group,
    replace => $purge_config,
    content => $content
  })
}
