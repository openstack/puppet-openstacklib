#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Definition: openstacklib::service_validation
#
# This resource does service validation for an OpenStack service.
#
# == Parameters:
#
# [*command*]
# Command to run for validating the service;
# string; required
#
# [*service_name*]
# The name of the service to validate;
# string; optional; default to the $title of the resource, i.e. 'nova-api'
#
# [*path*]
# The path of the command to validate the service;
# string; optional; default to '/usr/bin:/bin:/usr/sbin:/sbin'
#
# [*provider*]
# The provider to use for the exec command;
# string; optional; default to 'shell'
#
# [*refreshonly*]
# If the service validation should only occur on a refresh/notification;
# boolean; optional; default to false
#
# [*timeout*]
# The maximum time the command should take;
# string; optional; default to '60'
#
# [*tries*]
# Number of times to retry validation;
# string; optional; default to '10'
#
# [*try_sleep*]
# Number of seconds between validation attempts;
# string; optional; default to '2'
#
# [*onlyif*]
# Run the exec if all conditions in the array return true.
# string or array; optional; default to 'undef'
#
# [*unless*]
# Run the exec if all conditions in the array return false.
# string or array; optional; default to 'undef'
#
define openstacklib::service_validation(
  $command,
  $service_name = $name,
  $path         = '/usr/bin:/bin:/usr/sbin:/sbin',
  $provider     = shell,
  $refreshonly  = false,
  $timeout      = '60',
  $tries        = '10',
  $try_sleep    = '2',
  $onlyif       = undef,
  $unless       = undef,
) {

  if $onlyif and $unless {
    fail ('Only one parameter should be declared: onlyif or unless')
  }

  exec { "execute ${service_name} validation":
    command     => $command,
    path        => $path,
    provider    => $provider,
    refreshonly => $refreshonly,
    timeout     => $timeout,
    tries       => $tries,
    try_sleep   => $try_sleep,
    onlyif      => $onlyif,
    unless      => $unless,
    logoutput   => 'on_failure',
  }

  anchor { "create ${service_name} anchor":
    require => Exec["execute ${service_name} validation"],
  }

}

