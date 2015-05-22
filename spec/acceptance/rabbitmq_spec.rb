require 'spec_helper_acceptance'

describe 'openstacklib class' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      if $::osfamily == 'RedHat' {
        # RabbitMQ is not available in default repo
        class { '::openstack_extras::repo::redhat::redhat':
          # Kilo is not GA yet, so let's use the testing repo
          manage_rdo => false,
          repo_hash  => {
            'rdo-kilo-testing' => {
              'baseurl'  => 'https://repos.fedorapeople.org/repos/openstack/openstack-kilo/testing/el7/',
              # packages are not GA so not signed
              'gpgcheck' => '0',
              'priority' => 97,
            },
          },
        }
        $package_provider = 'yum'
      } else {
        $package_provider = 'apt'
      }

      class { '::rabbitmq':
        delete_guest_user => true,
        erlang_cookie     => 'secrete',
        package_provider  => $package_provider
      }

      # openstacklib resources
      include ::openstacklib::openstackclient

      ::openstacklib::messaging::rabbitmq { 'beaker':
        userid   => 'beaker',
        is_admin => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command("rabbitmqctl list_users") do
      it { should return_stdout /^beaker/ }
      it { should_not return_stdout /^guest/ }
    end

    describe command('rabbitmqctl list_permissions') do
      it { should return_stdout /^beaker\t\.\*\t\.\*\t\.\*$/ }
    end

  end
end
