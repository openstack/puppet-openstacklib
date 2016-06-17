require 'puppet'
require 'puppet/type/policy_rcd'

describe Puppet::Type.type(:policy_rcd) do

  before :each do
    Puppet::Type.rmtype(:policy_rcd)
  end

  it 'should fail with wrong status code' do
    incorrect_input = {
      :name     => 'test_type',
      :set_code => '356'
    }
    expect { Puppet::Type.type(:policy_rcd).new(incorrect_input) }.to raise_error(Puppet::ResourceError, /Unknown exit status code is set/)
  end

  it 'should be compiled withour errors' do
    correct_input = {
      :name     => 'test_type',
      :set_code => '0'
    }
    expect { Puppet::Type.type(:policy_rcd).new(correct_input) }.to_not raise_error
  end
end
