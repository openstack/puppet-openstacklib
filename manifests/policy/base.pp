# == Definition: openstacklib::policy::base
#
# This resource configures the policy.json file for an OpenStack service
#
# == Parameters:
#
#  [*file_path*]
#    (required) Path to the policy.json file
#
#  [*key*]
#    (optional) The key to replace the value for
#    Defaults to $name
#
#  [*value*]
#    (optional) The value to set
#    Defaults to ''
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
#  [*purge_config*]
#    (optional) Whether to set only the specified policy rules in the policy
#    file.
#    Defaults to false.
#
define openstacklib::policy::base (
  Stdlib::Absolutepath $file_path,
  String[1] $key                    = $name,
  String $value                     = '',
  $file_mode                        = '0640',
  $file_user                        = undef,
  $file_group                       = undef,
  Enum['json', 'yaml'] $file_format = 'json',
  Boolean $purge_config             = false,
) {

  ensure_resource('openstacklib::policy::default', $file_path, {
    file_path    => $file_path,
    file_mode    => $file_mode,
    file_user    => $file_user,
    file_group   => $file_group,
    file_format  => $file_format,
    purge_config => $purge_config
  })

  case $file_format {
    'json': {
      warning('Json format is deprecated and will be removed in a future release')

      # Add entry if it doesn't exists
      augeas { "${file_path}-${key}-add":
        lens    => 'Json.lns',
        incl    => $file_path,
        changes => [
          "set dict/entry[last()+1] \"${key}\"",
          "set dict/entry[last()]/string \"${value}\"",
        ],
        onlyif  => "match dict/entry[*][.=\"${key}\"] size == 0",
      }

      # Requires that the entry is added before this call or it will fail.
      augeas { "${file_path}-${key}" :
        lens    => 'Json.lns',
        incl    => $file_path,
        changes => "set dict/entry[*][.=\"${key}\"]/string \"${value}\"",
      }

      Openstacklib::Policy::Default<| title == $file_path |>
      -> Augeas<| title == "${file_path}-${key}-add" |>
        ~> Augeas<| title == "${file_path}-${key}" |>
    }
    'yaml': {
      # NOTE(tkajianm): Currently we use single quotes('') to quote the whole
      #                 value, thus a single quote in value should be escaped
      #                 by another single quote (which results in '')
      # NOTE(tkajinam): Replace '' by ' first in case ' is already escaped
      $value_real = regsubst(regsubst($value, '\'\'', '\'', 'G'), '\'', '\'\'', 'G')

      file_line { "${file_path}-${key}" :
        path  => $file_path,
        line  => "'${key}': '${value_real}'",
        match => "^['\"]?${key}(?!:)['\"]?\\s*:.+"
      }
      Openstacklib::Policy::Default<| title == $file_path |>
      -> File_line<| title == "${file_path}-${key}" |>
    }
    default: {
      fail("${file_format} is an unsupported policy file format. Choose 'json' or 'yaml'.")
    }
  }

}
