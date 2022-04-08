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

  case $file_format {
    'json': {
      ensure_resource('file', $file_path, {
        mode    => $file_mode,
        owner   => $file_user,
        group   => $file_group,
        replace => false, # augeas will manage the content, we just need to make sure it exists
        content => '{}'
      })

      # Add entry if it doesn't exists
      augeas { "${file_path}-${key}-${value}-add":
        lens    => 'Json.lns',
        incl    => $file_path,
        changes => [
          "set dict/entry[last()+1] \"${key}\"",
          "set dict/entry[last()]/string \"${value}\"",
        ],
        onlyif  => "match dict/entry[*][.=\"${key}\"] size == 0",
      }

      # Requires that the entry is added before this call or it will fail.
      augeas { "${file_path}-${key}-${value}" :
        lens    => 'Json.lns',
        incl    => $file_path,
        changes => "set dict/entry[*][.=\"${key}\"]/string \"${value}\"",
      }

      File<| title == $file_path |>
      -> Augeas<| title == "${file_path}-${key}-${value}-add" |>
        ~> Augeas<| title == "${file_path}-${key}-${value}" |>
    }
    'yaml': {
      ensure_resource('file', $file_path, {
        mode    => $file_mode,
        owner   => $file_user,
        group   => $file_group,
        replace => false, # augeas will manage the content, we just need to make sure it exists
        content => ''
      })

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
      File<| title == $file_path |>
      -> File_line<| title == "${file_path}-${key}" |>
    }
    default: {
      fail("${file_format} is an unsupported policy file format. Choose 'json' or 'yaml'.")
    }
  }

}

