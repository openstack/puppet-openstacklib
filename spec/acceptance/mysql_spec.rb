require 'spec_helper_acceptance'

describe 'openstacklib mysql' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      class { 'mysql::server': }

      $charset = $::operatingsystem ? {
        'Ubuntu' => 'utf8mb3',
        default  => 'utf8',
      }

      openstacklib::db::mysql { 'ci':
        charset       => $charset,
        collate       => "${charset}_general_ci",
        password_hash => mysql::password('keystone'),
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

    it 'should have ci database' do
      command("mysql -e 'show databases;' | grep -q ci") do |r|
        expect(r.exit_code).to eq 0
      end
    end

  end
end
