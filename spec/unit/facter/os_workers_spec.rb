require 'spec_helper'

describe 'os_workers' do

  before { Facter.clear }

  context 'with processorcount=1' do
    before do
      Facter.fact(:processors).stubs(:value).returns({'count' => 1})
    end

    it 'returns a minimum of 2' do
      expect(Facter.fact(:os_workers).value).to eq(2)
    end
  end

  context 'with processorcount=8' do
    before do
      Facter.fact(:processors).stubs(:value).returns({'count' => 8})
    end

    it 'returns processorcount/2' do
      expect(Facter.fact(:os_workers).value).to eq(4)
    end
  end

  context 'with processorcount=32' do
    before do
      Facter.fact(:processors).stubs(:value).returns({'count' => 32})
    end

    it 'returns a maximum of 12' do
      expect(Facter.fact(:os_workers).value).to eq(12)
    end
  end
end
