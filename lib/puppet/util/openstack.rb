# Add the auth parameter to whatever type is given
module Puppet::Util::Openstack
  def self.add_openstack_type_methods(type, comment)

    type.newparam(:auth) do

      desc <<EOT
Hash of authentication credentials. Credentials can be specified as either :

1. Using a project/user with a password

For Keystone API V2:
auth => {
  'username'     => 'test',
  'password'     => 'changeme',
  'project_name' => 'test',
  'auth_url'     => 'http://localhost:35357/v2.0'
}

or altenatively for Keystone API V3:
auth => {
  'username'            => 'test',
  'password'            => 'changeme',
  'project_name'        => 'test',
  'project_domain_name' => 'domain1',
  'user_domain_name'    => 'domain1',
  'auth_url'            => 'http://localhost:35357/v3'
}

2. Using a path to an openrc file containing these credentials

auth => {
  'openrc' => '/root/openrc'
}

3. Using a service token

For Keystone API V2:
auth => {
  'token' => 'example',
  'url'   => 'http://localhost:35357/v2.0'
}

Alternatively for Keystone API V3:
auth => {
  'token' => 'example',
  'url'   => 'http://localhost:35357/v3.0'
}

If not present, the provider will look for environment variables for
password credentials.

#{comment}
EOT

      validate do |value|
        raise(Puppet::Error, 'This property must be a hash') unless value.is_a?(Hash)
      end
    end

    type.autorequire(:package) do
      'python-openstackclient'
    end

  end
end
