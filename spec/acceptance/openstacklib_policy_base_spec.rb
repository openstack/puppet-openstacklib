require 'spec_helper_acceptance'

describe 'policy file management' do

  context 'with policy.yaml' do
    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }
      openstacklib::policy::base { 'is_admin':
        file_path   => '/tmp/policy.yaml',
        key         => 'is_admin',
        value       => 'role:admin',
        file_format => 'yaml',
      }
      openstacklib::policy::base { 'is_member':
        file_path   => '/tmp/policy.yaml',
        key         => 'is_member',
        value       => 'role:member',
        file_format => 'yaml',
      }
      openstacklib::policy::base { 'get_router':
        file_path   => '/tmp/policy.yaml',
        key         => 'get_router',
        value       => 'rule:admin_or_owner',
        file_format => 'yaml',
      }
      openstacklib::policy::base { 'get_router:distributed':
        file_path   => '/tmp/policy.yaml',
        key         => 'get_router:distributed',
        value       => 'rule:admin_only',
        file_format => 'yaml',
      }

      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/policy.yaml') do
      it { should exist }
      it { should contain("'is_admin': 'role:admin'") }
      it { should contain("'is_member': 'role:member'") }
      it { should contain("'get_router': 'rule:admin_or_owner'") }
      it { should contain("'get_router:distributed': 'rule:admin_only'") }
    end
  end

end
