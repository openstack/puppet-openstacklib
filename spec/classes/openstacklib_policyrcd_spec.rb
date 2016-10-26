#
# Copyright (C) 2016 Matthew J. Black
#
# Author: Matthew J. Black <mjblack@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for openstacklib::policyrcd
#
require 'spec_helper'

describe 'openstacklib::policyrcd' do

  shared_examples_for 'openstacklib::policyrcd on Debian platforms' do
    context "with single service" do
      let :params do
        { :services => ['keystone'] }
      end

      let(:contents) {
        <<-eof
#!/bin/bash

if [ "$1" == "keystone" ]
then
  exit 101
fi


eof
      }

      it 'creates policy-rc.d file' do
        is_expected.to contain_file('/usr/sbin/policy-rc.d').with_content(contents)
      end
    end

    context "with multiple services" do
      let :params do
        { :services => ['keystone', 'nova'] }
      end

      let(:contents) {
        <<-eof
#!/bin/bash

if [ "$1" == "keystone" ]
then
  exit 101
fi

if [ "$1" == "nova" ]
then
  exit 101
fi


eof
      }

      it 'creates policy-rc.d file' do
        is_expected.to contain_file('/usr/sbin/policy-rc.d').with_content(contents)
      end
    end

  end

  shared_examples_for 'openstacklib::policyrcd on RedHat platforms' do
    describe "with single service" do
      let :params do
        { :services => ['keystone'] }
      end

      it 'does not create policy-rc.d file' do
        is_expected.to_not contain_file('/usr/sbin/policy-rc.d')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures "openstacklib::policyrcd on #{facts[:osfamily]} platforms"
    end
  end

end
