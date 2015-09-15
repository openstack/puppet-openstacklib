require 'spec_helper'

describe 'is_service_default' do

  it 'refuses without at least one argument' do
    is_expected.to run.with_params().\
      and_raise_error(Puppet::ParseError, /Wrong number of arguments/)
  end

  it 'refuses too many arguments' do
    is_expected.to run.with_params('foo', 'bar').\
      and_raise_error(Puppet::ParseError, /Wrong number of arguments/)
  end

  context 'is_service_default' do
    it 'with <SERVICE DEFAULT>' do
      is_expected.to run.with_params('<SERVICE DEFAULT>').and_return(true)
    end

    it 'with string != <SERVICE DEFAULT>' do
      is_expected.to run.with_params('a value').and_return(false)
    end

    it 'with array' do
      is_expected.to run.with_params([1,2,3]).and_return(false)
    end

    it 'with hash' do
      is_expected.to run.with_params({'foo' => 'bar'}).and_return(false)
    end

    it 'with integer' do
      is_expected.to run.with_params(1234).and_return(false)
    end

    it 'with boolean' do
      is_expected.to run.with_params(false).and_return(false)
    end
  end
end
