require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'
require 'vcr'


RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr'
  c.hook_into :faraday
end
