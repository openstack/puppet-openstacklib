# Allow a user to access the database for the service
#
# == Namevar
#  String with the form dbname_host. The host part of the string is the host
#  to allow
#
# == Parameters
#  [*user*]
#    username to allow
#
#  [*password_hash*]
#    user password hash
#
#  [*database*]
#    the database name
#
#  [*privileges*]
#    the privileges to grant to this user
#
#  [*create_user*]
#    Flag to allow for the skipping of the user as part of the database setup.
#    Set to false to skip the user creation.
#    Defaults to true.
#
#  [*create_grant*]
#    Flag to allow for the skipping of the user grants as part of the database
#    setup. Set to false to skip the user creation.
#    Defaults to true.
#
define openstacklib::db::mysql::host_access (
  $user,
  $password_hash,
  $database,
  $privileges,
  $create_user  = true,
  $create_grant = true,
) {
  validate_re($title, '_', 'Title must be $dbname_$host')

  $host = inline_template('<%= @title.split("_").last.downcase %>')

  if $create_user {
    mysql_user { "${user}@${host}":
      password_hash => $password_hash,
      require       => Mysql_database[$database],
    }
  }

  if $create_grant {
    mysql_grant { "${user}@${host}/${database}.*":
      privileges => $privileges,
      table      => "${database}.*",
      require    => Mysql_user["${user}@${host}"],
      user       => "${user}@${host}",
    }
  }
}
