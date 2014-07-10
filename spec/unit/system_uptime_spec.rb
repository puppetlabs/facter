#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/uptime'

describe "system_uptime:" do
  before { Facter.clear }
  after { Facter.clear }

  describe "When uptime information is available" do
    describe "uptime" do
      test_cases = [
        [60 * 60 * 24 * 3,      '3 days'],
        [60 * 60 * 24 * 3 + 25, '3 days'],
        [60 * 60 * 24 * 1,      '1 day'],
        [60 * 60 * 24 * 1 + 25, '1 day'],
        [60 * (60 * 3 + 45),    '3:45 hours'],
        [60 * (60 * 3 + 4),     '3:04 hours'],
        [60 * 60,               '1:00 hours'],
        [60 * 35,               '0:35 hours']
      ]

      test_cases.each do |seconds, expected|
        it "should return #{expected.inspect} for #{seconds} seconds in Linux" do
          Facter.fact(:kernel).stubs(:value).returns("linux")
          Facter::Util::Uptime.stubs(:get_uptime_seconds_unix).returns(seconds)
          Facter.fact(:system_uptime).value['uptime'].should eq expected
        end

        it "should return #{expected.inspect} for #{seconds} seconds in Windows" do
          Facter.fact(:kernel).stubs(:value).returns("windows")
          Facter::Util::Uptime.stubs(:get_uptime_seconds_win).returns(seconds)
          Facter.fact(:system_uptime).value['uptime'].should eq expected
        end
      end
    end
  end

  describe "when uptime information is available" do
    before do
      Facter::Util::Uptime.stubs(:get_uptime_seconds_unix).returns(60 * 60 * 24 + 23)
      Facter::Util::Uptime.stubs(:get_uptime_seconds_win).returns(60 * 60 * 24 + 23)
    end

    it "should include a key for seconds" do
      Facter.fact(:system_uptime).value['seconds'].should eq 60 * 60 * 24 + 23
    end

     it "should include a key for hours" do
      Facter.fact(:system_uptime).value['hours'].should eq 24
    end

    it "should include a key for days" do
      Facter.fact(:system_uptime).value['days'].should eq 1
    end
  end

  describe "when uptime information is not available" do
    before do
      Facter::Util::Uptime.stubs(:get_uptime_seconds_unix).returns(nil)
      Facter::Util::Uptime.stubs(:get_uptime_seconds_win).returns(nil)
    end

    it "should have an 'uptime' key with value 'unknown'" do
      Facter.fact(:system_uptime).value['uptime'].should eq "unknown"
    end

    it "should have a 'seconds' key with value nil" do
      Facter.fact(:system_uptime).value['seconds'].should eq nil
    end

    it "should have a 'hours' key with value nil" do
      Facter.fact(:system_uptime).value['hours'].should eq nil
    end

    it "should have a 'days' key with value nil" do
      Facter.fact(:system_uptime).value['days'].should eq nil
    end
  end
end
