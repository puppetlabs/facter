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
  describe "with_metadata_server", :focus => true do
    let(:gce) { Facter::Util::GCE }

    it 'returns false when not running on gce' do
      Facter.stubs(:value).with('virtual').returns('vmware')
      gce.with_metadata_server.should be_false
    end

    context 'default options and running on a gce virtual machine' do

      before :each do
        Facter.stubs(:value).with('virtual').returns('gce')
      end

      it 'returns false when the metadata server is unreachable' do
        described_class.stubs(:read_uri).raises(Errno::ENETUNREACH)
        gce.with_metadata_server.should be_false
      end

      it 'does not execute the block if the connection raises an exception' do
        described_class.stubs(:read_uri).raises(Timeout::Error)
        gce.with_metadata_server.should be_false
      end

      it 'succeeds on the third retry' do
        retry_metadata = sequence('metadata')
        Timeout.expects(:timeout).twice.in_sequence(retry_metadata).raises(Timeout::Error)
        Timeout.expects(:timeout).once.in_sequence(retry_metadata).returns(true)
        gce.with_metadata_server.should be_true
      end

      context 'with gce' do
        before do
          described_class.stubs(:read_uri).returns('{"some":"json"}')
        end

        it 'does not raise an error but returns false if json gem is not present' do
          Facter.stubs(:json?).returns(false)
          gce.with_metadata_server.should be_false
        end

        it 'warns if json gem is not present' do
          Facter.stubs(:json?).returns(false)
          Facter.expects(:warn).with("Cannot load GCE facts: no JSON gem available")
          gce.with_metadata_server.should be_false
        end
      end
    end
  end
end
