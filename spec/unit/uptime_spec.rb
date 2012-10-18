#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/uptime'

describe "uptime facts:" do
  before { Facter.clear }
  after { Facter.clear }

  describe "when uptime information is available" do
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
        it "should return #{expected.inspect} for #{seconds} seconds" do
          Facter::Util::Uptime.stubs(:get_uptime_seconds_unix).returns(seconds)
          Facter::Util::Uptime.stubs(:get_uptime_seconds_win).returns(seconds)

          Facter.fact(:uptime).value.should == expected
        end
      end
    end

  end

  describe "when uptime information is available" do
    before do
      Facter::Util::Uptime.stubs(:get_uptime_seconds_unix).returns(60 * 60 * 24 + 23)
      Facter::Util::Uptime.stubs(:get_uptime_seconds_win).returns(60 * 60 * 24 + 23)
    end

    describe "uptime_seconds" do
      it "should return the uptime in seconds" do
        Facter.fact(:uptime_seconds).value.should == 60 * 60 * 24 + 23
      end
    end

    describe "uptime_hours" do
      it "should return the uptime in hours" do
        Facter.fact(:uptime_hours).value.should == 24
      end
    end

    describe "uptime_days" do
      it "should return the uptime in days" do
        Facter.fact(:uptime_days).value.should == 1
      end
    end
  end

  describe "when uptime information is not available" do
    before do
      Facter::Util::Uptime.stubs(:get_uptime_seconds_unix).returns(nil)
      Facter::Util::Uptime.stubs(:get_uptime_seconds_win).returns(nil)
      $stderr, @old = StringIO.new, $stderr
    end

    after do
      $stderr = @old
    end

    describe "uptime" do
      it "should return 'unknown'" do
        Facter.fact(:uptime).value.should == "unknown"
      end
    end

    describe "uptime_seconds" do
      it "should return nil" do
        Facter.fact(:uptime_seconds).value.should == nil
      end

      it "should not print a warn message to stderr" do
        Facter.fact(:uptime_seconds).value
        $stderr.string.should == ""
      end
    end

    describe "uptime_hours" do
      it "should return nil" do
        Facter.fact(:uptime_hours).value.should == nil
      end

      it "should not print a warn message to stderr" do
        Facter.fact(:uptime_hours).value
        $stderr.string.should == ""
      end
    end

    describe "uptime_days" do
      it "should return nil" do
        Facter.fact(:uptime_days).value.should == nil
      end

      it "should not print a warn message to stderr" do
        Facter.fact(:uptime_days).value
        $stderr.string.should == ""
      end
    end
  end
end
