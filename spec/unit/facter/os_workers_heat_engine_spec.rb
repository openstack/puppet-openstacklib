require 'spec_helper'

describe 'os_workers_heat_engine' do

  before { Facter.flush }

  context 'with processorcount=1' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(1)
    end

    it 'returns a minimum of 2' do
      expect(Facter.fact(:os_workers_heat_engine).value).to eq(4)
    end
  end

  context 'with processorcount=8' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(8)
    end

    it 'returns processorcount/2' do
      expect(Facter.fact(:os_workers_heat_engine).value).to eq(4)
    end
  end

  context 'with processorcount=64' do
    before do
      Facter.fact(:processorcount).stubs(:value).returns(64)
    end

    it 'returns a maximum of 24' do
      expect(Facter.fact(:os_workers_heat_engine).value).to eq(24)
    end
  end
end
