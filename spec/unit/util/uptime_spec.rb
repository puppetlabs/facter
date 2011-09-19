#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/uptime'

describe Facter::Util::Uptime do

  describe ".get_uptime_seconds_unix", :unless => Facter.value(:operatingsystem) == 'windows' do
    describe "when /proc/uptime is available" do
      before do
        uptime_file = File.join(SPECDIR, "fixtures", "uptime", "ubuntu_proc_uptime")
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

      it "should use 'sysctl kern.boottime'" do
        if [1].pack("L") == [1].pack("V") # Determine endianness
          sysctl_output_filename = 'sysctl_kern_boottime_little_endian'
        else
          sysctl_output_filename = 'sysctl_kern_boottime_big_endian'
        end
        sysctl_output_file = File.join(SPECDIR, 'fixtures', 'uptime', sysctl_output_filename) # Aug 01 14:13:47 -0700 2010
        Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat \"#{sysctl_output_file}\"")
        Time.stubs(:now).returns Time.parse("Aug 01 15:13:47 -0700 2010") # one hour later
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
      end

      describe "nor is 'sysctl kern.boottime'" do
        before :each do
          Facter::Util::Uptime.stubs(:uptime_sysctl_cmd).returns("cat \"#{@nonexistent_file}\"")
        end

        it "should use 'kstat -p unix:::boot_time'" do
          kstat_output_file = File.join(SPECDIR, 'fixtures', 'uptime', 'kstat_boot_time') # unix:0:system_misc:boot_time    1236919980
          Facter::Util::Uptime.stubs(:uptime_kstat_cmd).returns("cat \"#{kstat_output_file}\"")
          Time.stubs(:now).returns Time.at(1236923580) #one hour later
          Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
        end

        describe "nor is 'kstat -p unix:::boot_time'" do
          before :each do
            Facter::Util::Uptime.stubs(:uptime_kstat_cmd).returns("cat \"#{@nonexistent_file}\"")
          end

          it "should use 'who -b'" do
            who_b_output_file = File.join(SPECDIR, 'fixtures', 'uptime', 'who_b_boottime') # Aug 1 14:13
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
