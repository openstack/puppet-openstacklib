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
# == Class: openstacklib::wsgi::apache
#
# Serve a service with apache mod_wsgi
# When using this class you should disable your service.
#
# == Parameters
#
# [*service_name*]
#   (optional) Name of the service to run.
#   Example: nova-api
#   Defaults to $name
#
# [*servername*]
#   (optional) The servername for the virtualhost.
#   Defaults to $::fqdn
#
# [*bind_host*]
#   (optional) The host/ip address Apache will listen on.
#   Defaults to undef (listen on all ip addresses).
#
# [*bind_port*]
#   (optional) The port to listen.
#   Defaults to undef
#
# [*group*]
#   (optional) Group with permissions on the script
#   Defaults to undef
#
# [*path*]
#   (optional) The prefix for the endpoint.
#   Defaults to '/'
#
# [*priority*]
#   (optional) The priority for the vhost.
#   Defaults to '10'
#
# [*ssl*]
#   (optional) Use ssl ? (boolean)
#   Defaults to false
#
# [*ssl_cert*]
#   (optional) Path to SSL certificate
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*ssl_key*]
#   (optional) Path to SSL key
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*ssl_chain*]
#   (optional) SSL chain
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*ssl_ca*]
#   (optional) Path to SSL certificate authority
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*ssl_crl_path*]
#   (optional) Path to SSL certificate revocation list
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*ssl_crl*]
#   (optional) SSL certificate revocation list name
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*ssl_certs_dir*]
#   (optional) Path to SSL certificate directory
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*threads*]
#   (optional) The number of threads for the vhost.
#   Defaults to $::os_workers
#
# [*user*]
#   (optional) User with permissions on the script
#   Defaults to undef
#
# [*workers*]
#   (optional) The number of workers for the vhost.
#   Defaults to '1'
#
# [*wsgi_daemon_process*]
#   (optional) Name of the WSGI daemon process.
#   Defaults to $name
#
# [*wsgi_process_display_name*]
#   (optional) Name of the WSGI process display-name.
#   Defaults to $name
#
# [*wsgi_process_group*]
#   (optional) Name of the WSGI process group.
#   Defaults to $name
#
# [*wsgi_script_dir*]
#   (optional) The directory path of the WSGI script.
#   Defaults to undef
#
# [*wsgi_script_file*]
#   (optional) The file path of the WSGI script.
#   Defaults to undef
#
# [*wsgi_script_source*]
#   (optional) The source of the WSGI script.
#   Defaults to undef
#
# [*wsgi_application_group*]
#   (optional) The application group of the WSGI script.
#   Defaults to '%{GLOBAL}'
#
# [*wsgi_pass_authorization*]
#   (optional) Whether HTTP authorisation headers are passed through to a WSGI
#   script when the equivalent HTTP request headers are present.
#   Defaults to undef
#
# [*wsgi_chunked_request*]
#   (optional) Makes the vhost allow chunked requests which is useful for
#   handling TE (Transfer-Encoding), chunked or gzip. This sets the
#   WSGIChunkedRequest option in the vhost.
#   Defaults to undef
#
# [*custom_wsgi_process_options*]
#   (optional) gives you the oportunity to add custom process options or to
#   overwrite the default options for the WSGI process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*vhost_custom_fragment*]
#   (optional) Passes a string of custom configuration
#   directives to be placed at the end of the vhost configuration.
#   Defaults to undef.
#
# [*allow_encoded_slashes*]
#   (optional) If set, uses apache's AllowEncodedSlashes option in the vhost.
#   This option is passed to puppetlabs-apache, which accepts only 4
#   options: undef, "on", "off" or "nodecode". This is thus validated in the
#   underlying vhost resource.
#   Defaults to undef.
#
define openstacklib::wsgi::apache (
  $service_name                = $name,
  $bind_host                   = undef,
  $bind_port                   = undef,
  $group                       = undef,
  $path                        = '/',
  $priority                    = '10',
  $servername                  = $::fqdn,
  $ssl                         = false,
  $ssl_ca                      = undef,
  $ssl_cert                    = undef,
  $ssl_certs_dir               = undef,
  $ssl_chain                   = undef,
  $ssl_crl                     = undef,
  $ssl_crl_path                = undef,
  $ssl_key                     = undef,
  $threads                     = $::os_workers,
  $user                        = undef,
  $workers                     = 1,
  $wsgi_daemon_process         = $name,
  $wsgi_process_display_name   = $name,
  $wsgi_process_group          = $name,
  $wsgi_script_dir             = undef,
  $wsgi_script_file            = undef,
  $wsgi_script_source          = undef,
  $wsgi_application_group      = '%{GLOBAL}',
  $wsgi_pass_authorization     = undef,
  $wsgi_chunked_request        = undef,
  $custom_wsgi_process_options = {},
  $vhost_custom_fragment       = undef,
  $allow_encoded_slashes       = undef,
) {

  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  # Ensure there's no trailing '/' except if this is also the only character
  $path_real = regsubst($path, '(^/.*)/$', '\1')

  if !defined(File[$wsgi_script_dir]) {
    file { $wsgi_script_dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
    }
  }

  file { $service_name:
    ensure => file,
    links  => follow,
    path   => "${wsgi_script_dir}/${wsgi_script_file}",
    source => $wsgi_script_source,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  $wsgi_daemon_process_options = merge (
    {
      user         => $user,
      group        => $group,
      processes    => $workers,
      threads      => $threads,
      display-name => $wsgi_process_display_name,
    },
    $custom_wsgi_process_options,
  )
  $wsgi_script_aliases = hash([$path_real,"${wsgi_script_dir}/${wsgi_script_file}"])

  ::apache::vhost { $service_name:
    ensure                      => 'present',
    servername                  => $servername,
    ip                          => $bind_host,
    port                        => $bind_port,
    docroot                     => $wsgi_script_dir,
    docroot_owner               => $user,
    docroot_group               => $group,
    priority                    => $priority,
    setenvif                    => ['X-Forwarded-Proto https HTTPS=1'],
    ssl                         => $ssl,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    ssl_chain                   => $ssl_chain,
    ssl_ca                      => $ssl_ca,
    ssl_crl_path                => $ssl_crl_path,
    ssl_crl                     => $ssl_crl,
    ssl_certs_dir               => $ssl_certs_dir,
    wsgi_daemon_process         => $wsgi_daemon_process,
    wsgi_daemon_process_options => $wsgi_daemon_process_options,
    wsgi_process_group          => $wsgi_process_group,
    wsgi_script_aliases         => $wsgi_script_aliases,
    wsgi_application_group      => $wsgi_application_group,
    wsgi_pass_authorization     => $wsgi_pass_authorization,
    wsgi_chunked_request        => $wsgi_chunked_request,
    custom_fragment             => $vhost_custom_fragment,
    allow_encoded_slashes       => $allow_encoded_slashes,
  }

  Package<| title == 'httpd' |>
  ~> File<| title == $wsgi_script_dir |>
  ~> File<| title == $service_name |>
  ~> Apache::Vhost<| title == $service_name |>
}
