require 'beaker-rspec'

hosts.each do |host|

  install_puppet

  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|

      # install git
      install_package host, 'git'

      # clean out any module cruft
      shell('rm -fr /etc/puppet/modules/*')

      # install library modules from the forge
      on host, puppet('module','install','puppetlabs-mysql'), { :acceptable_exit_codes => 0 }
      on host, puppet('module','install','puppetlabs-rabbitmq'), { :acceptable_exit_codes => 0 }
      on host, puppet('module','install','puppetlabs-apache'), { :acceptable_exit_codes => 0 }
      on host, puppet('module','install','puppetlabs-postgresql'), { :acceptable_exit_codes => 0 }
      on host, puppet('module','install','stahnma-epel'), { :acceptable_exit_codes => 0 }
      shell('git clone https://git.openstack.org/openstack/puppet-openstack_extras /etc/puppet/modules/openstack_extras')
      # Install the module being tested
      puppet_module_install(:source => proj_root, :module_name => 'openstacklib')
      # List modules installed to help with debugging
      on host, puppet('module','list'), { :acceptable_exit_codes => 0 }
    end
  end
end