openstacklib
============

#### Table of Contents

1. [Overview - What is the openstacklib module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with openstacklib](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The openstacklib module is a part of [OpenStack](https://github.com/openstack),
an effort by the Openstack infrastructure team to provide continuous integration
testing and code review for Openstack and Openstack community projects not part
of the core software.  The module itself is used to expose common functionality
between Openstack modules as a library that can be utilized to avoid code
duplication.

Module Description
------------------

The openstacklib module is a library module for other Openstack modules to
utilize. A thorough description will be added later.

This module is tested in combination with other modules needed to build and
leverage an entire Openstack software stack.

Setup
-----

### Installing openstacklib

    puppet module install openstack/openstacklib

Usage
-----

### Classes and Defined Types

#### Defined type: openstacklib::db::mysql

The db::mysql resource is a library resource that can be used by nova, cinder,
ceilometer, etc., to create a mysql database with configurable privileges for
a user connecting from defined hosts.

Typically this resource will be declared with a notify parameter to configure
the sync command to execute when the database resource is changed.

For example, in heat::db::mysql you might declare:

```
::openstacklib::db::mysql { 'heat':
    password_hash => mysql_password($password),
    dbname        => $dbname,
    user          => $user,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
    notify        => Exec['heat-dbsync'],
  }
```

Some modules should ensure that the database is created before the service is
set up. For example, in keystone::db::mysql you would have:

```
::openstacklib::db::mysql { 'keystone':
    password_hash => mysql_password($password),
    dbname        => $dbname,
    user          => $user,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
    notify        => Exec['keystone-manage db_sync'],
    before        => Service['keystone'],
  }
```

** Parameters for openstacklib::db::mysql: **

#####`password_hash`
Password hash to use for the database user for this service;
string; required

#####`dbname`
The name of the database
string; optional; default to the $title of the resource, i.e. 'nova'

#####`user`
The database user to create;
string; optional; default to the $title of the resource, i.e. 'nova'

#####`host`
The IP address or hostname of the user in mysql_grant;
string; optional; default to '127.0.0.1'

#####`charset`
The charset to use for the database;
string; optional; default to 'utf8'

#####`collate`
The collate to use for the database;
string; optional; default to 'utf8_general_ci'

#####`allowed_hosts`
Additional hosts that are allowed to access this database;
array or string; optional; default to undef

#####`privileges`
Privileges given to the database user;
string or array of strings; optional; default to 'ALL'

#### Defined type: openstacklib::db::postgresql

The db::postgresql resource is a library resource that can be used by nova,
cinder, ceilometer, etc., to create a postgresql database and a user with
configurable privileges.

Typically this resource will be declared with a notify parameter to configure
the sync command to execute when the database resource is changed.

For example, in heat::db::postgresql you might declare:

```
::openstacklib::db::postgresql { $dbname:
  password_hash => postgresql_password($user, $password),
  dbname        => $dbname,
  user          => $user,
  notify        => Exec['heat-dbsync'],
}
```

Some modules should ensure that the database is created before the service is
set up. For example, in keystone::db::postgresql you would have:

```
::openstacklib::db::postgresql { $dbname:
  password_hash => postgresql_password($user, $password),
  dbname        => $dbname,
  user          => $user,
  notify        => Exec['keystone-manage db_sync'],
  before        => Service['keystone'],
}
```

** Parameters for openstacklib::db::postgresql: **

#####`password_hash`
Password hash to use for the database user for this service;
string; required

#####`dbname`
The name of the database
string; optional; default to the $title of the resource, i.e. 'nova'

#####`user`
The database user to create;
string; optional; default to the $title of the resource, i.e. 'nova'

#####`encoding`
The encoding use for the database;
string; optional; default to undef

#####`privileges`
Privileges given to the database user;
string or array of strings; optional; default to 'ALL'

#### Defined type: openstacklib::service_validation

The service_validation resource is a library resource that can be used by nova, cinder,
ceilometer, etc., to validate that a resource is actually up and running.

For example, in nova::api you might declare:

```
::openstacklib::service_validation { 'nova-api':
    command => 'nova list',
  }
```
This defined resource creates an exec-anchor pair where the anchor depends upon
the successful exec run.

** Parameters for openstacklib::service_validation: **

#####`command`
Command to run for validating the service;
string; required

#####`service_name`
The name of the service to validate;
string; optional; default to the $title of the resource, i.e. 'nova-api'

#####`path`
The path of the command to validate the service;
string; optional; default to '/usr/bin:/bin:/usr/sbin:/sbin'

#####`provider`
The provider to use for the exec command;
string; optional; default to 'shell'

#####`tries`
Number of times to retry validation;
string; optional; default to '10'

#####`try_sleep`
Number of seconds between validation attempts;
string; optional; default to '2'

#### Defined provider for openstack_config: ini_setting

It provides an interface to any INI configuration file as they are
used in Openstack modules.

You use it like this:

```
Puppet::Type.type(:<module>_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do
```

It has the standard features of the upstream puppetlabs' `inifile`
module as it's a direct children of it.  Furthermore it can transform
a value with some function of you're choice, enabling you to get value
that get filled at run-time like an `uuid`.

For an example of how that's working you can have a look at this
[review](https://review.openstack.org/#/c/347468/)

#### Defined provider for openstack_config: ruby

This one has the same basic features as the ini_setting one but the
ability to transformation the value.  It offers another feature,
though.  It can parse array.  What it enables one to do is to parse
this correctly:

```
[DEFAULT]
conf1 = value1
conf1 = value2
```

On the opposite side if you put that:

```
module_config { 'DEFAULT/conf1' : value => ['value1', 'value2'] }
```

in your manifest, it will properly be written as the example above.

To use this provider you use this:

```
Puppet::Type.type(:<module>_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do
```

and define you type with ```:array_matching => :all```.  An example of
such provider is ```nova_config```.  Have a look for inspiration.

Implementation
--------------

### openstacklib

openstacklib is a combination of Puppet manifest and ruby code to delivery
configuration and extra functionality through types and providers.

Limitations
-----------

The python-migrate system package for RHEL 6 and below is out of date and may
fail to correctly migrate postgresql databases. While this module does not
handle database migrations, it is common to set up refresh relationships
between openstacklib::db::postgresql resource and the database sync exec
resource. Relying on this behavior may cause errors.

Beaker-Rspec
------------

This module has beaker-rspec tests

To run:

```shell
bundle install
bundle exec rspec spec/acceptance
```

Development
-----------

Developer documentation for the entire puppet-openstack project.

* http://docs.openstack.org/developer/puppet-openstack-guide/

Contributors
------------

* https://github.com/stackforge/puppet-openstacklib/graphs/contributors

Versioning
----------

This module has been given version 5 to track the puppet-openstack modules. The
versioning for the puppet-openstack modules are as follows:

```
Puppet Module :: OpenStack Version :: OpenStack Codename
2.0.0         -> 2013.1.0          -> Grizzly
3.0.0         -> 2013.2.0          -> Havana
4.0.0         -> 2014.1.0          -> Icehouse
5.0.0         -> 2014.2.0          -> Juno
6.0.0         -> 2015.1.0          -> Kilo
7.0.0         -> 2015.2.0          -> Liberty
```
