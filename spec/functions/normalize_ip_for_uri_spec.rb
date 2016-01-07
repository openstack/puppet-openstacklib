require 'spec_helper'

describe 'normalize_ip_for_uri' do
  it { should run.with_params(false).and_return(false)}
  it { should run.with_params('not_an_ip').and_return('not_an_ip')}
  it { should run.with_params('127.0.0.1').and_return('127.0.0.1')}
  it { should run.with_params('::1').and_return('[::1]')}
  it { should run.with_params('[2001::01]').and_return('[2001::01]')}
  it do
    is_expected.to run.with_params('one', 'two')
      .and_raise_error(ArgumentError, /Wrong number of arguments/)
  end
end
