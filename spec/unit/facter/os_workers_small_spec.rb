require 'spec_helper'

describe 'os_workers_small' do

  before { Facter.flush }

  context 'with processorcount=1' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(1)
    end

    it 'returns a minimum of 2' do
      expect(Facter.fact(:os_workers_small).value).to eq(2)
    end
  end

  context 'with processorcount=16' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(16)
    end

    it 'returns processorcount/4' do
      expect(Facter.fact(:os_workers_small).value).to eq(4)
    end
  end

  context 'with processorcount=32' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(32)
    end

    it 'returns a maximum of 8' do
      expect(Facter.fact(:os_workers_small).value).to eq(8)
    end
  end
end
