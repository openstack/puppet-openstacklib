require 'spec_helper'

describe 'os_workers_large' do

  before { Facter.clear }

  context 'with processorcount=1' do
    before do
      Facter.fact(:processors).stubs(:value).returns({'count' => 1})
    end

    it 'returns a minimum of 1' do
      expect(Facter.fact(:os_workers_large).value).to eq(1)
    end
  end

  context 'with processorcount=8' do
    before do
      Facter.fact(:processors).stubs(:value).returns({'count' => 8})
    end

    it 'returns processorcount/2' do
      expect(Facter.fact(:os_workers_large).value).to eq(4)
    end
  end
end
