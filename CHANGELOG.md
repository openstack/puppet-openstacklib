## 8.0.0 and beyond

From 8.0.0 release and beyond, release notes are published on
[docs.openstack.org](http://docs.openstack.org/releasenotes/puppet-openstacklib/).

##2015-11-24 - 7.0.0
###Summary

This is a backwards-compatible major release for OpenStack Liberty.

####Features
- fallback to default rcfile
- prepare $::os_package_type
- add a proxy inifile provider
- allow the use of an ensure_absent_val param
- create is_service_default function
- create os_service_default fact
- allow to path custom fragment to vhost
- pass necessary options to Apache when using WSGI

####Bugfixes
- fix fact for puppet facter 2.0.1+

####Maintenance
- initial msync run for all Puppet OpenStack modules
- enable acceptance tests for openstack_config
- remove class_parameter_defaults puppet-lint check

##2015-10-10 - 6.1.0
###Summary

This is a maintenance release in the Kilo series.

####Maintenance
- acceptance: checkout stable/kilo puppet modules

##2015-07-08 - 6.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Kilo.

####Backwards-incompatible changes
- MySQL: change default MySQL collate to utf8_general_ci

####Features
- Puppet 4.x support
- Add db::postgresql to openstacklib
- Implement openstacklib::wsgi::apache
- Move openstackclient parent provider to openstacklib
- Keystone V3 API support
- Restructures authentication for resource providers

####Bugfixes
- Properly handle policy values containing spaces

####Maintenance
- Bump mysql version to 3.x
- Acceptance tests with Beaker

##2015-06-17 - 5.1.0
###Summary

This is a feature and bugfix release in the Juno series.

####Features
- Adding augeas insertion check

####Bugfixes
- MySQL: change default MySQL collate to utf8_general_ci

####Maintenance
- Update .gitreview file for project rename
- spec: pin rspec-puppet to 1.0.1

##2014-11-25 - 5.0.0
###Summary

Initial release for Juno.
