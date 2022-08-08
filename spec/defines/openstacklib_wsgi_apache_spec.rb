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

require 'spec_helper'

describe 'openstacklib::wsgi::apache' do
  let (:title) { 'keystone_wsgi' }

  let :global_facts do
    {
      :os_workers     => 8,
      :concat_basedir => '/var/lib/puppet/concat',
      :fqdn           => 'some.host.tld'
    }
  end

  let :params do
    {
      :bind_port          => 5000,
      :group              => 'keystone',
      :ssl                => true,
      :ssl_verify_client  => 'optional',
      :user               => 'keystone',
      :wsgi_script_dir    => '/var/www/cgi-bin/keystone',
      :wsgi_script_file   => 'main',
      :wsgi_script_source => '/usr/share/keystone/keystone.wsgi',
    }
  end

  shared_examples 'openstacklib::wsgi::apache' do
    it {
      should contain_service('httpd').with_name(platform_params[:httpd_service_name])
      should contain_class('apache')
      should contain_class('apache::mod::wsgi')
    }

    context 'with default parameters' do
      it { should contain_file('/var/www/cgi-bin/keystone').with(
        :ensure => 'directory',
        :owner  => 'keystone',
        :group  => 'keystone',
        :mode   => '0755',
      )}

      it { should contain_file('keystone_wsgi').with(
        :ensure => 'file',
	:links  => 'follow',
        :path   => '/var/www/cgi-bin/keystone/main',
        :source => '/usr/share/keystone/keystone.wsgi',
        :owner  => 'keystone',
        :group  => 'keystone',
        :mode   => '0644',
      )}

      it { should contain_apache__vhost('keystone_wsgi').with(
        :servername                  => 'some.host.tld',
        :ip                          => nil,
        :port                        => '5000',
        :docroot                     => '/var/www/cgi-bin/keystone',
        :docroot_owner               => 'keystone',
        :docroot_group               => 'keystone',
        :setenv                      => [],
        :ssl                         => 'true',
        :ssl_verify_client           => 'optional',
        :wsgi_daemon_process         => {
          'keystone_wsgi' => {
            'user'         => 'keystone',
            'group'        => 'keystone',
            'processes'    => global_facts[:os_workers],
            'threads'      => 1,
            'display-name' => 'keystone_wsgi',
          }},
        :wsgi_process_group          => 'keystone_wsgi',
        :wsgi_script_aliases         => { '/' => "/var/www/cgi-bin/keystone/main" },
        :wsgi_application_group      => '%{GLOBAL}',
        :headers                     => nil,
        :request_headers             => nil,
        :aliases                     => nil,
        :setenvif                    => ['X-Forwarded-Proto https HTTPS=1'],
        # TODO(tkajinam): Replace false by undef once the new puppetlabs-apache
        #                 is released.
        # https://github.com/puppetlabs/puppetlabs-apache/commit/f41251e3
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
        :log_level                   => nil,
        :options                     => ['-Indexes', '+FollowSymLinks','+MultiViews'],
      )}

      it { should contain_concat("#{platform_params[:httpd_ports_file]}") }
    end

    context 'when overriding parameters' do
      let :params do
        {
          :wsgi_script_dir            => '/var/www/cgi-bin/keystone',
          :wsgi_script_file           => 'main',
          :wsgi_script_source         => '/usr/share/keystone/keystone.wsgi',
          :wsgi_pass_authorization    => 'On',
          :wsgi_chunked_request       => 'On',
          :custom_wsgi_script_aliases => {
            '/admin' => '/var/www/cgi-bin/keystone/admin'
          },
          :headers                    => 'set X-Frame-Options "DENY"',
          :request_headers            => 'set Content-Type "application/json"',
          :aliases                    => [
            { 'alias' => '/robots.txt', 'path'  => '/etc/keystone/robots.txt', }
          ],
          :servername                 => 'dummy.host',
          :bind_host                  => '10.42.51.1',
          :bind_port                  => 4142,
          :user                       => 'keystone',
          :group                      => 'keystone',
          :setenv                     => ['MYENV foo'],
          :ssl                        => false,
          :workers                    => 37,
          :vhost_custom_fragment      => 'LimitRequestFieldSize 81900',
          :allow_encoded_slashes      => 'on',
          :access_log_file            => '/var/log/httpd/access_log',
          :access_log_syslog          => 'syslog:local0',
          :access_log_format          => 'some format',
          :error_log_file             => '/var/log/httpd/error_log',
          :error_log_syslog           => 'syslog:local0',
          :log_level                  => 'reqtimeout:info',
        }
      end

      it { should contain_apache__vhost('keystone_wsgi').with(
        :servername                  => 'dummy.host',
        :ip                          => '10.42.51.1',
        :port                        => '4142',
        :docroot                     => "/var/www/cgi-bin/keystone",
        :setenv                      => ['MYENV foo'],
        :ssl                         => 'false',
        :wsgi_daemon_process         => {
          'keystone_wsgi' => {
            'user'         => 'keystone',
            'group'        => 'keystone',
            'processes'    => '37',
            'threads'      => '1',
            'display-name' => 'keystone_wsgi',
          }},
        :wsgi_process_group          => 'keystone_wsgi',
        :wsgi_script_aliases         => {
          '/'      => '/var/www/cgi-bin/keystone/main',
          '/admin' => '/var/www/cgi-bin/keystone/admin',
        },
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_pass_authorization     => 'On',
        :wsgi_chunked_request        => 'On',
        :headers                     => 'set X-Frame-Options "DENY"',
        :request_headers             => 'set Content-Type "application/json"',
        :aliases                    => [
          { 'alias' => '/robots.txt', 'path' => '/etc/keystone/robots.txt', }
        ],
        :custom_fragment             => 'LimitRequestFieldSize 81900',
        :allow_encoded_slashes       => 'on',
        :access_log_file             => '/var/log/httpd/access_log',
        :access_log_syslog           => 'syslog:local0',
        :access_log_format           => 'some format',
        :error_log_file              => '/var/log/httpd/error_log',
        :error_log_syslog            => 'syslog:local0',
        :log_level                   => 'reqtimeout:info',
      )}
    end

    context 'when wsgi_daemon_process_options are overridden' do
      let :params do
        {
          :bind_port                   => 5000,
          :group                       => 'keystone',
          :ssl                         => true,
          :user                        => 'keystone',
          :wsgi_script_dir             => '/var/www/cgi-bin/keystone',
          :wsgi_script_file            => 'main',
          :wsgi_script_source          => '/usr/share/keystone/keystone.wsgi',
          :custom_wsgi_process_options => {
            'user'        => 'someotheruser',
            'group'       => 'someothergroup',
            'python_path' => '/my/python/admin/path',
          },
        }
      end

      it { should contain_apache__vhost('keystone_wsgi').with(
        :wsgi_daemon_process => {
          'keystone_wsgi' => {
            'user'         => 'someotheruser',
            'group'        => 'someothergroup',
            'processes'    => global_facts[:os_workers],
            'threads'      => 1,
            'display-name' => 'keystone_wsgi',
            'python_path'  => '/my/python/admin/path',
          }},
      )}
    end

    context 'with multiple ports' do
      before do
        params.merge!( :bind_port => [35357, 5000] )
      end

      it { should contain_apache__vhost('keystone_wsgi').with_port(params[:bind_port]) }
    end

    context 'with set_wsgi_import_script enabled' do
      let :params do
        {
          :bind_port              => 5000,
          :group                  => 'keystone',
          :ssl                    => true,
          :user                   => 'keystone',
          :wsgi_script_dir        => '/var/www/cgi-bin/keystone',
          :wsgi_script_file       => 'main',
          :wsgi_script_source     => '/usr/share/keystone/keystone.wsgi',
          :set_wsgi_import_script => true,
        }
      end
      it { should contain_apache__vhost('keystone_wsgi').with(
          :wsgi_import_script_options => {
            'process-group'     => 'keystone_wsgi',
            'application-group' => '%{GLOBAL}',
          }
      )}
    end
    context 'with custom wsgi_import_script and options' do
      let :params do
        {
          :bind_port              => 5000,
          :group                  => 'keystone',
          :ssl                    => true,
          :user                   => 'keystone',
          :wsgi_script_dir        => '/var/www/cgi-bin/keystone',
          :wsgi_script_file       => 'main',
          :wsgi_script_source     => '/usr/share/keystone/keystone.wsgi',
          :set_wsgi_import_script => true,
          :wsgi_import_script     => '/foo/bar',
          :wsgi_import_script_options => {
            'process-group'     => 'foo',
            'application-group' => 'bar',
          },
        }
      end
      it { should contain_apache__vhost('keystone_wsgi').with(
          :wsgi_import_script         => '/foo/bar',
          :wsgi_import_script_options => {
            'process-group'     => 'foo',
            'application-group' => 'bar',
          }
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts(global_facts))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :httpd_service_name => 'apache2',
            :httpd_ports_file   => '/etc/apache2/ports.conf'
          }
        when 'RedHat'
          {
            :httpd_service_name => 'httpd',
            :httpd_ports_file   => '/etc/httpd/conf/ports.conf'
          }
        end
      end

      it_behaves_like 'openstacklib::wsgi::apache'
    end
  end
end
