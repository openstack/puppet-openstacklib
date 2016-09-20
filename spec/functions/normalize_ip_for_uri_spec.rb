require 'spec_helper'

describe 'normalize_ip_for_uri' do
  it { should run.with_params(false).and_return(false)}
  it { should run.with_params('not_an_ip').and_return('not_an_ip')}
  it { should run.with_params('127.0.0.1').and_return('127.0.0.1')}
  it { should run.with_params('::1').and_return('[::1]')}
  it { should run.with_params('[2001::01]').and_return('[2001::01]')}
  # You're not forced to pass an array, a list of argument will do.
  it { should run.with_params('::1','::2').and_return(['[::1]','[::2]'])}
  it { should run.with_params(['::1','::2']).and_return(['[::1]','[::2]'])}
  it { should run.with_params(['::1','[::2]','::3']).and_return(['[::1]','[::2]','[::3]'])}
  it { should run.with_params(['192.168.0.1','[::2]']).and_return(['192.168.0.1','[::2]'])}
  it { should run.with_params(['192.168.0.1','::2']).and_return(['192.168.0.1','[::2]'])}
end
