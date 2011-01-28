#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/macosx'

describe Facter::Util::Macosx do
    it "should be able to retrieve profiler data as xml for a given data field" do
        Facter::Util::Resolution.expects(:exec).with("/usr/sbin/system_profiler -xml foo").returns "yay"
        Facter::Util::Macosx.profiler_xml("foo").should == "yay"
    end

    it "should use PList to convert xml to data structures" do
        Plist.expects(:parse_xml).with("foo").returns "bar"

        Facter::Util::Macosx.intern_xml("foo").should == "bar"
    end

    describe "when collecting profiler data" do
        it "should return the first value in the '_items' hash in the first value of the results of the system_profiler data, with the '_name' field removed, if the profiler returns data" do
            @result = [
                '_items' => [
                    {'_name' => "foo", "yay" => "bar"}
                ]
            ]
            Facter::Util::Macosx.expects(:profiler_xml).with("foo").returns "eh"
            Facter::Util::Macosx.expects(:intern_xml).with("eh").returns @result
            Facter::Util::Macosx.profiler_data("foo").should == {"yay" => "bar"}
        end

        it "should return nil if an exception is thrown during parsing of xml" do
            Facter::Util::Macosx.expects(:profiler_xml).with("foo").returns "eh"
            Facter::Util::Macosx.expects(:intern_xml).with("eh").raises "boo!"
            Facter::Util::Macosx.profiler_data("foo").should be_nil
        end
    end

    it "should return the profiler data for 'SPHardwareDataType' as the hardware information" do
        Facter::Util::Macosx.expects(:profiler_data).with("SPHardwareDataType").returns "eh"
        Facter::Util::Macosx.hardware_overview.should == "eh"
    end

    it "should return the profiler data for 'SPSoftwareDataType' as the os information" do
        Facter::Util::Macosx.expects(:profiler_data).with("SPSoftwareDataType").returns "eh"
        Facter::Util::Macosx.os_overview.should == "eh"
    end
    
    describe "when working out software version" do
        
        before do
            Facter::Util::Resolution.expects(:exec).with("/usr/bin/sw_vers -productName").returns "Mac OS X"
            Facter::Util::Resolution.expects(:exec).with("/usr/bin/sw_vers -buildVersion").returns "9J62"
        end
        
        it "should have called sw_vers three times when determining software version" do
            Facter::Util::Resolution.expects(:exec).with("/usr/bin/sw_vers -productVersion").returns "10.5.7"
            Facter::Util::Macosx.sw_vers
        end
    
        it "should return a hash with the correct keys when determining software version" do
            Facter::Util::Resolution.expects(:exec).with("/usr/bin/sw_vers -productVersion").returns "10.5.7"
            Facter::Util::Macosx.sw_vers.keys.sort.should == ["macosx_productName",
                                                              "macosx_buildVersion",
                                                              "macosx_productversion_minor",
                                                              "macosx_productversion_major",
                                                              "macosx_productVersion"].sort
        end
    
        it "should split a product version of 'x.y.z' into separate hash entries correctly" do
            Facter::Util::Resolution.expects(:exec).with("/usr/bin/sw_vers -productVersion").returns "1.2.3"
            sw_vers = Facter::Util::Macosx.sw_vers
            sw_vers["macosx_productversion_major"].should == "1.2"
            sw_vers["macosx_productversion_minor"].should == "3"
        end
    
        it "should treat a product version of 'x.y' as 'x.y.0" do
            Facter::Util::Resolution.expects(:exec).with("/usr/bin/sw_vers -productVersion").returns "2.3"
            Facter::Util::Macosx.sw_vers["macosx_productversion_minor"].should == "0"
        end
    end
end
