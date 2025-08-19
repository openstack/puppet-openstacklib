# == Definition: openstacklib::db::mysql
#
# This resource configures a mysql database for an OpenStack service
#
# == Parameters:
#
#  [*password*]
#    Password to use for the database user for this service;
#    string; required
#
#  [*plugin*]
#    Authentication plugin to use when connecting to the MySQL server;
#    string; optional; default to 'undef'
#
#  [*dbname*]
#    The name of the database
#    string; optional; default to the $title of the resource, i.e. 'nova'
#
#  [*user*]
#    The database user to create;
#    string; optional; default to the $title of the resource, i.e. 'nova'
#
#  [*host*]
#    The IP address or hostname of the user in mysql_grant;
#    string; optional; default to '127.0.0.1'
#
#  [*charset*]
#    The charset to use for the database;
#    string; optional; default to 'utf8'
#
#  [*collate*]
#    The collate to use for the database;
#    string; optional; default to 'utf8_general_ci'
#
#  [*allowed_hosts*]
#    Additional hosts that are allowed to access this database;
#    array or string; optional; default to undef
#
#  [*privileges*]
#    Privileges given to the database user;
#    string or array of strings; optional; default to 'ALL'
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
# DEPRECATED PARAMETERS
#
#  [*password_hash*]
#    Password hash to use for the database user for this service;
#    string; optional; default to undef
#
define openstacklib::db::mysql (
  Optional[String[1]] $password                       = undef,
  Optional[String[1]] $plugin                         = undef,
  String[1] $dbname                                   = $title,
  String[1] $user                                     = $title,
  String[1] $host                                     = '127.0.0.1',
  String[1] $charset                                  = 'utf8',
  String[1] $collate                                  = 'utf8_general_ci',
  Variant[String[1], Array[String[1]]] $allowed_hosts = [],
  Variant[String[1], Array[String[1]]] $privileges    = 'ALL',
  Boolean $create_user                                = true,
  Boolean $create_grant                               = true,
  Variant[String[1], Array[String[1]]] $tls_options   = ['NONE'],
  # DEPRECATED PARAMETER
  Optional[String[1]] $password_hash                  = undef,
) {
  include mysql::server
  include mysql::client

  if $password_hash != undef {
    warning("The password_hash parameter was deprecated and will be removed \
in a future release. Use password instead")
    $password_hash_real = $password_hash
  } elsif $password != undef {
    $password_hash_real = mysql::password($password)
  } else {
    fail('password should be set')
  }

  mysql_database { $dbname:
    ensure  => present,
    charset => $charset,
    collate => $collate,
  }

  Class['mysql::server'] ~> Mysql_database<| title == $dbname |>
  Class['mysql::client'] ~> Mysql_database<| title == $dbname |>

  if $create_user or $create_grant {
    $allowed_hosts_list = unique(concat(any2array($allowed_hosts), [$host]))
    $real_allowed_hosts = prefix($allowed_hosts_list, "${dbname}_")

    openstacklib::db::mysql::host_access { $real_allowed_hosts:
      user          => $user,
      plugin        => $plugin,
      password_hash => $password_hash_real,
      database      => $dbname,
      privileges    => $privileges,
      create_user   => $create_user,
      create_grant  => $create_grant,
      tls_options   => $tls_options,
    }
  }
}
