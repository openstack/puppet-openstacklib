require 'spec_helper_acceptance'

describe 'openstacklib class' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      class { '::rabbitmq':
        delete_guest_user => true,
        erlang_cookie     => 'secrete',
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
