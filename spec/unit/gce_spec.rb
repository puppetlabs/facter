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
    let(:gce) { Facter::Util::GCE }
    let(:url) { "#{api_prefix}/#{api_version}/?recursive=true&alt=json" }
    before :each do
      # Assume we can connect
      gce.stubs(:can_connect?).returns(true)
      Facter.stubs(:value).
        with('virtual').returns('gce')
    end

    it "defines facts dynamically from metadata/" do
      pending "Example cannot run without the 'json' library" unless Facter.json?

      gce.expects(:read_uri).with(url).returns('{"some_key_name":"some_key_value"}')

      expect(gce.add_gce_facts(:force => true)).to be_true
      Facter.fact(:gce_some_key_name).value.should eq("some_key_value")
    end

    it "returns false if json gem is not present." do
      gce.stubs(:require_json).returns(false)

      gce.add_gce_facts(:force => true).should be_false
      Facter.to_hash.keys.should_not include('gce_some')
    end
  end
end
