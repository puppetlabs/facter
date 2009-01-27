#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/macosx'

describe Facter::Macosx do
    it "should be able to retrieve profiler data as xml for a given data field" do
        Facter::Util::Resolution.expects(:exec).with("/usr/sbin/system_profiler -xml foo").returns "yay"
        Facter::Macosx.profiler_xml("foo").should == "yay"
    end

    it "should use PList to convert xml to data structures" do
        Plist.expects(:parse_xml).with("foo").returns "bar"

        Facter::Macosx.intern_xml("foo").should == "bar"
    end

    describe "when collecting profiler data" do
        it "should return the first value in the '_items' hash in the first value of the results of the system_profiler data, with the '_name' field removed, if the profiler returns data" do
            @result = [
                '_items' => [
                    {'_name' => "foo", "yay" => "bar"}
                ]
            ]
            Facter::Macosx.expects(:profiler_xml).with("foo").returns "eh"
            Facter::Macosx.expects(:intern_xml).with("eh").returns @result
            Facter::Macosx.profiler_data("foo").should == {"yay" => "bar"}
        end

        it "should return nil if an exception is thrown during parsing of xml" do
            Facter::Macosx.expects(:profiler_xml).with("foo").returns "eh"
            Facter::Macosx.expects(:intern_xml).with("eh").raises "boo!"
            Facter::Macosx.profiler_data("foo").should be_nil
        end
    end

    it "should return the profiler data for 'SPHardwareDataType' as the hardware information" do
        Facter::Macosx.expects(:profiler_data).with("SPHardwareDataType").returns "eh"
        Facter::Macosx.hardware_overview.should == "eh"
    end

    it "should return the profiler data for 'SPSoftwareDataType' as the os information" do
        Facter::Macosx.expects(:profiler_data).with("SPSoftwareDataType").returns "eh"
        Facter::Macosx.os_overview.should == "eh"
    end
end
