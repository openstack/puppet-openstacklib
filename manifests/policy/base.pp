# == Definition: openstacklib::policy::base
#
# This resource configures the policy.json file for an OpenStack service
#
# == Parameters:
#
#  [*file_path*]
#    Path to the policy.json file
#    string; required
#
#  [*key*]
#    The key to replace the value for
#    string; required; the key to replace the value for
#
#  [*value*]
#    The value to set
#    string; optional; the value to set
#
#  [*file_mode*]
#    (optional) Permission mode for the policy file
#    Defaults to '0640'
#
#  [*file_user*]
#    (optional) User for the policy file
#    Defaults to undef
#
#  [*file_group*]
#    (optional) Group for the policy file
#    Defaults to undef
#
#  [*file_format*]
#    (optional) Format for file contents. Valid values
#    are 'json' or 'yaml'.
#    Defaults to 'json'.
#
define openstacklib::policy::base (
  $file_path,
  $key,
  $value       = '',
  $file_mode   = '0640',
  $file_user   = undef,
  $file_group  = undef,
  $file_format = 'json',
) {

  ensure_resource('file', $file_path, {
    mode    => $file_mode,
    owner   => $file_user,
    group   => $file_group,
    replace => false, # augeas will manage the content, we just need to make sure it exists
    content => '{}'
  })

  case $file_format {
    'json': {
      $file_lens = 'Json.lns'
    }
    'yaml': {
      $file_lens = 'Yaml.lns'
    }
    default: {
      fail("${file_format} is an unsupported policy file format. Choose 'json' or 'yaml'.")
    }
  }


  # Add entry if it doesn't exists
  augeas { "${file_path}-${key}-${value}-add":
    lens    => $file_lens,
    incl    => $file_path,
    changes => [
      "set dict/entry[last()+1] \"${key}\"",
      "set dict/entry[last()]/string \"${value}\"",
    ],
    onlyif  => "match dict/entry[*][.=\"${key}\"] size == 0",
  }

  # Requires that the entry is added before this call or it will fail.
  augeas { "${file_path}-${key}-${value}" :
    lens    => $file_lens,
    incl    => $file_path,
    changes => "set dict/entry[*][.=\"${key}\"]/string \"${value}\"",
  }

  File<| title == $file_path |>
  -> Augeas<| title == "${file_path}-${key}-${value}-add" |>
    ~> Augeas<| title == "${file_path}-${key}-${value}" |>

}

