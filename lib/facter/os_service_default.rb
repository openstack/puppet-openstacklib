#
# This adds the os_service_default fact for people with facter < 2.0.1
# For people with facter >= 2.0.1, the facts.d/os_service_default.txt should
# provide this information
#
require 'puppet/util/package'

if Puppet::Util::Package.versioncmp(Facter.value(:facterversion), '2.0.1') < 0
  Facter.add('os_service_default') do
    setcode do
      '<SERVICE DEFAULT>'
    end
  end
end
