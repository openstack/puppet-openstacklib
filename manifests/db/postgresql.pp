# == Definition: openstacklib::db::postgresql
#
# This resource configures a postgresql database for an OpenStack service
#
# == Parameters:
#
#  [*password*]
#    Password to use for the database user for this service;
#    string; required
#
#  [*dbname*]
#    The name of the database
#    string; optional; default to the $title of the resource, i.e. 'nova'
#
#  [*user*]
#    The database user to create;
#    string; optional; default to the $title of the resource, i.e. 'nova'
#
#  [*encoding*]
#    The charset to use for the database;
#    string; optional; default to undef
#
#  [*privileges*]
#    Privileges given to the database user;
#    string or array of strings; optional; default to 'ALL'
#
# DEPRECATED PARAMETERS
#
#  [*password_hash*]
#    Password hash to use for the database user for this service;
#    string; required
#
define openstacklib::db::postgresql (
  $password      = undef,
  $dbname        = $title,
  $user          = $title,
  $encoding      = undef,
  $privileges    = 'ALL',
  # DEPRECATED PARAMETERS
  $password_hash = undef,
){

  if $password_hash != undef {
    warning('The password_hash parameter was deprecated and will be removed
in a future release. Use password instead')
    $password_hash_real = $password_hash
  } elsif $password != undef {
    $password_hash_real = postgresql::postgresql_password($user, $password)
  } else {
    fail('password should be set')
  }

  postgresql::server::db { $dbname:
    user     => $user,
    password => $password_hash_real,
    encoding => $encoding,
    grant    => $privileges,
  }
}
