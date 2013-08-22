#! /usr/bin/env ruby
# Copyright 2013 Google Inc. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'facter/util/gce'

describe "gce facts" do
  # This is the standard prefix for making an API call in GCE (or fake)
  # environments.
  let(:api_prefix) { "http://metadata/computeMetadata" }
  let(:api_version) { "v1beta1" }

  describe "when running on gce" do
    before :each do
      # Assume we can connect
      Facter::Util::GCE.stubs(:can_connect?).returns(true)
      Facter::Util::GCE.stubs(:read_uri).
        with('http://metadata').returns('OK')
      Facter.stubs(:value).
        with('virtual').returns('gce')
    end

    let :util do
      Facter::Util::GCE
    end

    it "defines facts dynamically from metadata/", :if => Facter.json? do
      util.stubs(:read_uri).
        with("#{api_prefix}/#{api_version}/?recursive=true&alt=json").
        returns('{"some_key_name":"some_key_value"}')

        Facter::Util::GCE.add_gce_facts(:force => true)
  
        Facter.fact(:gce_some_key_name).
          value.should == "some_key_value"
    end

    it "raises a LoadError if json gem is not present.", :unless => Facter.json? do
      util.stubs(:read_uri).returns('{"some":"json"}')
      expect { Facter::Util::GCE.add_gce_facts(:force => true) }.to raise_error(LoadError, /no json gem/)
    end
  end
end
