require 'spec_helper_acceptance'

describe 'openstacklib mysql' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      class { '::mysql::server': }

      ::openstacklib::db::mysql { 'beaker':
        password_hash => mysql_password('keystone'),
        allowed_hosts => '127.0.0.1',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(3306) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe command("mysql --defaults-file=/root/.my.cnf -e 'show databases;' | grep -q beaker") do
      it { should return_exit_status 0 }
    end

  end
end
