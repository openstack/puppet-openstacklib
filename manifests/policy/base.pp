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
define openstacklib::policy::base (
  $file_path,
  $key,
  $value = '',
) {

  # Add entry if it doesn't exists
  augeas { "${file_path}-${key}-${value}-add":
    lens    => 'Json.lns',
    incl    => $file_path,
    changes => [
      "set /files/${file_path}/dict/entry[last()+1] \"${key}\"",
      "set /files/${file_path}/dict/entry[last()]/string \"${value}\""
    ],
    onlyif  => "match /files/${file_path}/dict/entry[*][.=\"${key}\"] size == 0"
  }

  # Requires that the entry is added before this call or it will fail.
  augeas { "${file_path}-${key}-${value}-change" :
    lens    => 'Json.lns',
    incl    => $file_path,
    changes => "set dict/entry[*][.=\"${key}\"]/string ${value}",
    require => Augeas["${file_path}-${key}-${value}-add"]
  }

}

