require 'spec_helper'

describe 'os_workers_keystone' do

  before { Facter.flush }

  context 'with processorcount=1' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(1)
    end

    it 'returns a minimum of 4' do
      expect(Facter.fact(:os_workers_keystone).value).to eq(4)
    end
  end

  context 'with processorcount=8' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(8)
    end

    it 'returns processorcount' do
      expect(Facter.fact(:os_workers_keystone).value).to eq(8)
    end
  end

  context 'with processorcount=32' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(32)
    end

    it 'returns a maximum of 24' do
      expect(Facter.fact(:os_workers_keystone).value).to eq(24)
    end
  end
end
