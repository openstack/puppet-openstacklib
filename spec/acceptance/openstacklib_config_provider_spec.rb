require 'spec_helper_acceptance'

describe 'basic config provider resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # We create the file manually here because we only want to test
      # the logic of the provider hence installing the whole stack would
      # result in some overhead that is already tested in puppet-keystone
      File <||> -> Keystone_config <||>
      file { '/etc/keystone' :
        ensure => directory,
      }
      file { '/etc/keystone/keystone.conf' :
        ensure => file,
      }

      keystone_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      keystone_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      keystone_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      keystone_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/keystone/keystone.conf') do
      it { should exist }
      it { should contain('thisshouldexist=foo') }
      it { should contain('thisshouldexist2=<SERVICE DEFAULT>') }

      its(:content) { should_not match /thisshouldnotexist/ }
    end


  end
end
