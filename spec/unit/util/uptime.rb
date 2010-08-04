#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/uptime'

describe Facter::Util::Uptime do

  describe ".get_uptime_seconds_unix" do
    context "when /proc/uptime is available" do
      before do
        uptime_file = File.join(SPECDIR, "fixtures", "uptime", "ubuntu_proc_uptime")
        Facter::Util::Uptime.stubs(:uptime_file).returns(uptime_file)
      end

      it "should return the uptime in seconds as an integer" do
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 5097686
      end

    end

    it "should use sysctl kern.boottime when /proc/uptime not available" do
      nonexistent_file = '/non/existent/file'
      File.exists?(nonexistent_file).should == false
      Facter::Util::Uptime.stubs(:uptime_file).returns(nonexistent_file)
      sysctl_output_file = File.join(SPECDIR, 'fixtures', 'uptime', 'sysctl_kern_boottime') # Aug 01 14:13:47 -0700 2010
      Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat #{sysctl_output_file}")
      Time.stubs(:now).returns Time.parse("Aug 01 15:13:47 -0700 2010") # one hour later
      Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
    end

    it "should use who -b when neither /proc/uptime nor sysctl kern.boottime is available" do
      nonexistent_file = '/non/existent/file'
      File.exists?(nonexistent_file).should == false
      Facter::Util::Uptime.stubs(:uptime_file).returns(nonexistent_file)
      Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat #{nonexistent_file}")
      who_b_output_file = File.join(SPECDIR, 'fixtures', 'uptime', 'who_b_boottime') # Aug 1 14:13
      Facter::Util::Uptime.stubs(:uptime_who_cmd).returns("cat #{who_b_output_file}")
      Time.stubs(:now).returns Time.parse("Aug 01 15:13") # one hour later
      Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
    end

    it "should return nil when none of /proc/uptime, sysctl kern.boottime, or who -b is available" do
      nonexistent_file = '/non/existent/file'
      File.exists?(nonexistent_file).should == false
      Facter::Util::Uptime.stubs(:uptime_file).returns(nonexistent_file)
      Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat #{nonexistent_file}")
      Facter::Util::Uptime.stubs(:uptime_who_cmd).returns("cat #{nonexistent_file}")
      Facter::Util::Uptime.get_uptime_seconds_unix.should == nil
    end
  end

end
