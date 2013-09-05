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

describe Facter::Util::GCE do
  describe "with_metadata_server" do
    let(:gce) { Facter::Util::GCE }

    it 'returns false when not running on gce' do
      Facter.stubs(:value).with('virtual').returns('vmware')
      gce.with_metadata_server {|body| body}.should be_false
    end

    context 'default options and running on a gce virtual machine' do
      before :each do
        Facter.stubs(:value).with('virtual').returns('gce')
      end

      it 'returns false when the metadata server is unreachable' do
        described_class.stubs(:read_uri).raises(Errno::ENETUNREACH)
        gce.with_metadata_server {|body| body }.should be_false
      end

      it 'does not execute the block if the connection raises an exception' do
        described_class.stubs(:read_uri).raises(Timeout::Error)
        gce.with_metadata_server {|body| body }.should be_false
      end

      it 'succeeds on the third retry' do
        retry_metadata = sequence('metadata')
        described_class.stubs(:read_uri).twice.in_sequence(retry_metadata).raises(Errno::EHOSTUNREACH)
        described_class.stubs(:read_uri).once.in_sequence(retry_metadata).returns('RESPONSE BODY')

        gce.with_metadata_server {|body| body }.should eq('RESPONSE BODY')
      end

      it 'passes the response body to the block' do
        described_class.stubs(:read_uri).returns('RESPONSE BODY')

        gce.with_metadata_server {|body| body }.should eq('RESPONSE BODY')
      end
    end
  end
end
