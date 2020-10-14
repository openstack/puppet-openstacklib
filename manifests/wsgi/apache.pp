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
#   (Optional) Name of the service to run.
#   Example: nova-api
#   Defaults to $name
#
# [*servername*]
#   (Optional) The servername for the virtualhost
#   Defaults to $::fqdn
#
# [*bind_host*]
#   (Optional) The host/ip address Apache will listen on.
#   Defaults to undef (listen on all ip addresses)
#
# [*bind_port*]
#   (Optional) The port to listen.
#   Defaults to undef
#
# [*group*]
#   (Optional) Group with permissions on the script.
#   Defaults to undef
#
# [*path*]
#   (Optional) The prefix for the endpoint.
#   Defaults to '/'
#
# [*priority*]
#   (Optional) The priority for the vhost.
#   Defaults to '10'
#
# [*setenv*]
#   (Optional) Set environment variables for the vhost.
#   Defaults to []
#
# [*ssl*]
#   (Optional) Use SSL.
#   Defaults to false
#
# [*ssl_cert*]
#   (Optional) Path to SSL certificate.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_key*]
#   (Optional) Path to SSL key.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_verify_client*]
#   (Optional) Sets the SSLVerifyClient directive which sets the
#   certificate verification level for client authentication.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_chain*]
#   (Optional) SSL chain.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_ca*]
#   (Optional) Path to SSL certificate authority.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_crl_path*]
#   (Optional) Path to SSL certificate revocation list.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_crl*]
#   (Optional) SSL certificate revocation list name.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_certs_dir*]
#   (Optional) Path to SSL certificate directory
#   Default to apache::vhost 'ssl_*' defaults
#
# [*threads*]
#   (Optional) The number of threads for the vhost.
#   Defaults to 1
#
# [*user*]
#   (Optional) User with permissions on the script
#   Defaults to undef
#
# [*workers*]
#   (Optional) The number of workers for the vhost.
#   Defaults to $::os_workers
#
# [*wsgi_daemon_process*]
#   (Optional) Name of the WSGI daemon process.
#   Defaults to $name
#
# [*wsgi_process_display_name*]
#   (Optional) Name of the WSGI process display-name.
#   Defaults to $name
#
# [*wsgi_process_group*]
#   (Optional) Name of the WSGI process group.
#   Defaults to $name
#
# [*wsgi_script_dir*]
#   (Optional) The directory path of the WSGI script.
#   Defaults to undef
#
# [*wsgi_script_file*]
#   (Optional) The file path of the WSGI script.
#   Defaults to undef
#
# [*wsgi_script_source*]
#   (Optional) The source of the WSGI script.
#   Defaults to undef
#
# [*wsgi_application_group*]
#   (Optional) The application group of the WSGI script.
#   Defaults to '%{GLOBAL}'
#
# [*wsgi_pass_authorization*]
#   (Optional) Whether HTTP authorisation headers are passed through to a WSGI
#   script when the equivalent HTTP request headers are present.
#   Defaults to undef
#
# [*wsgi_chunked_request*]
#   (Optional) Makes the vhost allow chunked requests which is useful for
#   handling TE (Transfer-Encoding), chunked or gzip. This sets the
#   WSGIChunkedRequest option in the vhost.
#   Defaults to undef
#
# [*set_wsgi_import_script*]
#   (Optional) Enable WSGIImportScript.
#   Defaults to false
#
# [*wsgi_import_script*]
#   (Optional) WSGIImportScript path.
#   Defaults to undef
#   If not set and set_wsgi_import_script is true, defaults to the WSGI
#   application module path
#
# [*wsgi_import_script_options*]
#   (Optional) Sets WSGIImportScript options.
#   Defaults to undef
#   If not set and set_wsgi_import_script is true, push a dict as follow:
#   {
#     process-group     => $wsgi_daemon_process,
#     application-group => $wsgi_application_group,
#   }
#
# [*headers*]
#   (Optional) Headers for the vhost.
#   Defaults to undef
#
# [*aliases*]
#   (Optional) Aliases for the vhost.
#   Defaults to undef
#
# [*custom_wsgi_process_options*]
#   (Optional) gives you the oportunity to add custom process options or to
#   overwrite the default options for the WSGI process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*custom_wsgi_script_aliases*]
#   (Optional) Pass a hash with any extra WSGI script aliases that you want
#   to load for the same vhost, this is then combined with the default
#   script alias built usin $path, $wsgi_script_dir and $wsgi_script_file.
#   Defaults to undef
#
# [*vhost_custom_fragment*]
#   (Optional) Passes a string of custom configuration
#   directives to be placed at the end of the vhost configuration.
#   Defaults to undef
#
# [*allow_encoded_slashes*]
#   (Optional) If set, uses apache's AllowEncodedSlashes option in the vhost.
#   This option is passed to puppetlabs-apache, which accepts only 4
#   options: undef, "on", "off" or "nodecode". This is thus validated in the
#   underlying vhost resource.
#   Defaults to undef
#
# [*access_log_file*]
#   (Optional) The log file name for the virtualhost.
#   access_log_file and access_log_pipe is mutually exclusive.
#   Defaults to false
#
# [*access_log_pipe*]
#   (Optional) Specifies a pipe where Apache sends access logs for the virtualhost.
#   access_log_file and access_log_pipe is mutually exclusive.
#   Defaults to false
#
# [*access_log_syslog*]
#   (Optional) Sends the virtualhost access log messages to syslog.
#   Defaults to false
#
# [*access_log_format*]
#   (Optional) The log format for the virtualhost.
#   Defaults to false
#
# [*error_log_file*]
#   (Optional) The error log file name for the virtualhost.
#   error_log_file and error_log_pipe is mutually exclusive.
#   Defaults to undef
#
# [*error_log_pipe*]
#   (Optional) Specifies a pipe where Apache sends error logs for the virtualhost.
#   error_log_file and error_log_pipe is mutually exclusive.
#   Defaults to undef
#
# [*error_log_syslog*]
#   (Optional) Sends the virtualhost error log messages to syslog.
#   Defaults to undef
#
define openstacklib::wsgi::apache (
  $service_name                = $name,
  $servername                  = $::fqdn,
  $bind_host                   = undef,
  $bind_port                   = undef,
  $group                       = undef,
  $path                        = '/',
  $priority                    = '10',
  $setenv                      = [],
  $ssl                         = false,
  $ssl_ca                      = undef,
  $ssl_cert                    = undef,
  $ssl_certs_dir               = undef,
  $ssl_chain                   = undef,
  $ssl_crl                     = undef,
  $ssl_crl_path                = undef,
  $ssl_key                     = undef,
  $ssl_verify_client           = undef,
  $threads                     = 1,
  $user                        = undef,
  $workers                     = $::os_workers,
  $wsgi_daemon_process         = $name,
  $wsgi_process_display_name   = $name,
  $wsgi_process_group          = $name,
  $wsgi_script_dir             = undef,
  $wsgi_script_file            = undef,
  $wsgi_script_source          = undef,
  $wsgi_application_group      = '%{GLOBAL}',
  $wsgi_pass_authorization     = undef,
  $wsgi_chunked_request        = undef,
  $set_wsgi_import_script      = false,
  $wsgi_import_script          = undef,
  $wsgi_import_script_options  = undef,
  $headers                     = undef,
  $aliases                     = undef,
  $custom_wsgi_process_options = {},
  $custom_wsgi_script_aliases  = undef,
  $vhost_custom_fragment       = undef,
  $allow_encoded_slashes       = undef,
  $access_log_file             = false,
  $access_log_pipe             = false,
  $access_log_syslog           = false,
  $access_log_format           = false,
  $error_log_file              = undef,
  $error_log_pipe              = undef,
  $error_log_syslog            = undef,
) {

  include apache
  include apache::mod::wsgi
  if $ssl {
    include apache::mod::ssl
  }

  # Ensure there's no trailing '/' except if this is also the only character
  $path_real = regsubst($path, '(^/.*)/$', '\1')

  if !defined(File[$wsgi_script_dir]) {
    file { $wsgi_script_dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
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

  $wsgi_script_aliases_default = hash([$path_real,"${wsgi_script_dir}/${wsgi_script_file}"])

  if $custom_wsgi_script_aliases {
    $wsgi_script_aliases_real = merge($wsgi_script_aliases_default, $custom_wsgi_script_aliases)
  } else {
    $wsgi_script_aliases_real = $wsgi_script_aliases_default
  }

  # Sets WSGIImportScript related options
  if $set_wsgi_import_script {
    if $wsgi_import_script {
      $wsgi_import_script_real = $wsgi_import_script
    } else {
      $wsgi_import_script_real = $wsgi_script_aliases_real[$path_real]
    }
    if $wsgi_import_script_options {
      $wsgi_import_script_options_real = $wsgi_import_script_options
    } else {
      $wsgi_import_script_options_real = {
          process-group     => $wsgi_daemon_process,
          application-group => $wsgi_application_group,
        }
    }
  } else {
    $wsgi_import_script_real = undef
    $wsgi_import_script_options_real = undef
  }
  # End of WSGIImportScript related options

  ::apache::vhost { $service_name:
    ensure                     => 'present',
    servername                 => $servername,
    ip                         => $bind_host,
    port                       => $bind_port,
    docroot                    => $wsgi_script_dir,
    docroot_owner              => $user,
    docroot_group              => $group,
    priority                   => $priority,
    setenv                     => $setenv,
    setenvif                   => ['X-Forwarded-Proto https HTTPS=1'],
    ssl                        => $ssl,
    ssl_cert                   => $ssl_cert,
    ssl_key                    => $ssl_key,
    ssl_verify_client          => $ssl_verify_client,
    ssl_chain                  => $ssl_chain,
    ssl_ca                     => $ssl_ca,
    ssl_crl_path               => $ssl_crl_path,
    ssl_crl                    => $ssl_crl,
    ssl_certs_dir              => $ssl_certs_dir,
    wsgi_daemon_process        => hash([$wsgi_daemon_process, $wsgi_daemon_process_options]),
    wsgi_process_group         => $wsgi_process_group,
    wsgi_script_aliases        => $wsgi_script_aliases_real,
    wsgi_application_group     => $wsgi_application_group,
    wsgi_pass_authorization    => $wsgi_pass_authorization,
    wsgi_chunked_request       => $wsgi_chunked_request,
    wsgi_import_script         => $wsgi_import_script_real,
    wsgi_import_script_options => $wsgi_import_script_options_real,
    headers                    => $headers,
    aliases                    => $aliases,
    custom_fragment            => $vhost_custom_fragment,
    allow_encoded_slashes      => $allow_encoded_slashes,
    access_log_file            => $access_log_file,
    access_log_pipe            => $access_log_pipe,
    access_log_syslog          => $access_log_syslog,
    access_log_format          => $access_log_format,
    error_log_file             => $error_log_file,
    error_log_pipe             => $error_log_pipe,
    error_log_syslog           => $error_log_syslog,
    options                    => ['-Indexes', '+FollowSymLinks','+MultiViews'],
  }

  Package<| title == 'httpd' |>
  ~> File<| title == $wsgi_script_dir |>
  ~> File<| title == $service_name |>
  ~> Apache::Vhost<| title == $service_name |>
}
