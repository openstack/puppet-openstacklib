require 'spec_helper'

describe 'Openstacklib::Policies' do
  describe 'valid types' do
    context 'with valid types' do
      [
        {},
        {'name' => {'key' => 'mykey', 'value' => 'myvalue'}},
        {'name' => {'value' => 'myvalue'}},
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        {'name' => {}},
        {'name' => {'key' => 'mykey'}},
        {'name' => {'key' => 1, 'value' => 'myvalue'}},
        {'name' => {'key' => 'mykey', 'value' => 1}},
        {'name' => {'key' => 'mykey', 'value' => 'myvalue', 'foo' => 'bar'}},
        {'name' => {'value' => 'myvalue', 'foo' => 'bar'}},
        {0 => {'key' => 1, 'value' => 'myvalue'}},
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end

