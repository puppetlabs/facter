#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/uptime'

describe Facter::Util::Uptime do

  describe ".get_uptime_seconds_unix", :unless => Facter.value(:operatingsystem) == 'windows' do
    describe "when /proc/uptime is available" do
      before do
        uptime_file = my_fixture("ubuntu_proc_uptime")
        Facter::Util::Uptime.stubs(:uptime_file).returns("\"#{uptime_file}\"")
      end

      it "should return the uptime in seconds as an integer" do
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 5097686
      end

    end

    describe "when /proc/uptime is not available" do
      before :each do
        @nonexistent_file = '/non/existent/file'
        File.exists?(@nonexistent_file).should == false
        Facter::Util::Uptime.stubs(:uptime_file).returns(@nonexistent_file)
      end

      it "should use 'sysctl -n kern.boottime' on OpenBSD" do
        sysctl_output_file = my_fixture('sysctl_kern_boottime_openbsd') # Dec 09 21:11:46 +0000 2011
        Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat \"#{sysctl_output_file}\"")
        Time.stubs(:now).returns Time.parse("Dec 09 22:11:46 +0000 2011") # one hour later
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
      end

      it "should use 'sysctl -n kern.boottime' on Darwin, etc." do
        sysctl_output_file = my_fixture('sysctl_kern_boottime_darwin') # Oct 30 21:52:27 +0000 2011
        Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat \"#{sysctl_output_file}\"")
        Time.stubs(:now).returns Time.parse("Oct 30 22:52:27 +0000 2011") # one hour later
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
      end

      describe "nor is 'sysctl kern.boottime'" do
        before :each do
          Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat \"#{@nonexistent_file}\"")
        end

        it "should use 'kstat -p unix:::boot_time'" do
          kstat_output_file = my_fixture('kstat_boot_time') # unix:0:system_misc:boot_time    1236919980
          Facter::Util::Uptime.stubs(:uptime_kstat_cmd).returns("cat \"#{kstat_output_file}\"")
          Time.stubs(:now).returns Time.at(1236923580) #one hour later
          Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
        end

        describe "nor is 'kstat -p unix:::boot_time'" do
          before :each do
            Facter::Util::Uptime.stubs(:uptime_kstat_cmd).returns("cat \"#{@nonexistent_file}\"")
          end

          it "should use 'who -b'" do
            who_b_output_file = my_fixture('who_b_boottime') # Aug 1 14:13
            Facter::Util::Uptime.stubs(:uptime_who_cmd).returns("cat \"#{who_b_output_file}\"")
            Time.stubs(:now).returns Time.parse("Aug 01 15:13") # one hour later
            Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
          end

          describe "nor is 'who -b'" do
            before :each do
              Facter::Util::Uptime.stubs(:uptime_who_cmd).returns("cat \"#{@nonexistent_file}\"")
            end

            it "should return nil" do
              Facter::Util::Uptime.get_uptime_seconds_unix.should == nil
            end
          end
        end
      end
    end
  end

  describe ".get_uptime_seconds_win", :if => Facter.value(:operatingsystem) == 'windows' do
    it "should return a postive value" do
      Facter::Util::Uptime.get_uptime_seconds_win.should > 0
    end
  end
end
