#
# Copyright (C) 2016 Matthew J. Black
#
# Author: Matthew J. Black <mjblack@gmail.com>
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
# == Class: openstacklib::policyrcd
#
# [*services*]
# (required) The services that should be in the policy-rc.d shell script
# that should not autostart on install.
#
class openstacklib::policyrcd(
  $services
) {

  validate_array($services)

  if $::osfamily == 'Debian' {
    # We put this out there so openstack services wont auto start
    # when installed.
    file { '/usr/sbin/policy-rc.d':
      ensure  => present,
      content => template('openstacklib/policy-rc.d.erb'),
      mode    => '0755',
      owner   => root,
      group   => root,
    }

    File['/usr/sbin/policy-rc.d'] -> Package<| tag == 'openstack' |>
  }
}
