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

  let :params do
    { :services => ['keystone']
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  context 'on Debian platform' do

    let :facts do
      @default_facts.merge(test_facts.merge(
        { :osfamily => 'Debian' }
      ))
    end

    describe "with default value" do

      it 'creates policy-rc.d file' do
        verify_contents(catalogue, '/usr/sbin/policy-rc.d', [
          '#!/bin/bash',
          '',
          'if [ "$1" == "keystone" ]',
          'then',
          '  exit 101',
          'fi'
        ])
      end
    end
  end
end
