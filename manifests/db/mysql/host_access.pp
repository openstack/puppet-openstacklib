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
#  [*plugin*]
#    Authentication plugin to use when connecting to the MySQL server;
#    Defaults to undef
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
#  [*tls_options*]
#    The TLS options that the user will have
#    Defaults to ['NONE']
#
define openstacklib::db::mysql::host_access (
  String[1] $user,
  String[1] $password_hash,
  String[1] $database,
  Variant[String[1], Array[String[1]]] $privileges,
  Optional[String[1]] $plugin                       = undef,
  Boolean $create_user                              = true,
  Boolean $create_grant                             = true,
  Variant[String[1], Array[String[1]]] $tls_options = ['NONE'],
) {

  if ! ($title =~ /_/) {
    fail('Title must be $dbname_$host')
  }

  $host = inline_template('<%= @title.split("_").last.downcase %>')

  if $create_user {
    mysql_user { "${user}@${host}":
      plugin        => $plugin,
      password_hash => $password_hash,
      tls_options   => $tls_options,
    }
    Mysql_database<| title == $database |>
      ~> Mysql_user<| title == "${user}@${host}" |>
  }

  if $create_grant {
    mysql_grant { "${user}@${host}/${database}.*":
      privileges => $privileges,
      table      => "${database}.*",
      user       => "${user}@${host}",
    }
    Mysql_user<| title == "${user}@${host}" |>
      ~> Mysql_grant<| title == "${user}@${host}/${database}.*" |>
  }
}
