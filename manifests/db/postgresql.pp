# == Definition: openstacklib::db::postgresql
#
# This resource configures a postgresql database for an OpenStack service
#
# == Parameters:
#
#  [*password_hash*]
#    Password hash to use for the database user for this service;
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

define openstacklib::db::postgresql (
  $password_hash,
  $dbname     = $title,
  $user       = $title,
  $encoding   = undef,
  $privileges = 'ALL',
){

  postgresql::server::db { $dbname:
    user     => $user,
    password => $password_hash,
    encoding => $encoding,
    grant    => $privileges,
  }
}
