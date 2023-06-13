require 'spec_helper'

describe 'Openstacklib::ServiceDefault' do
  describe 'valid types' do
    context 'with valid types' do
      [
        '<SERVICE DEFAULT>',
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
        'somethink',
        true,
        nil,
        {},
        '',
        55555,
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end

