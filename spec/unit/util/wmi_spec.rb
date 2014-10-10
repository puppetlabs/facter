#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/wmi'

describe Facter::Util::WMI do
  let(:connection) { stub 'connection' }

  it "should default to localhost" do
    Facter::Util::WMI.wmi_resource_uri.should == "winmgmts:{impersonationLevel=impersonate}!//./root/cimv2"
  end

  it "should execute the query on the connection" do
    Facter::Util::WMI.stubs(:connect).returns(connection)
    connection.stubs(:execquery).with("select * from Win32_OperatingSystem")

    Facter::Util::WMI.execquery("select * from Win32_OperatingSystem")
  end

  it "re-queries WMI after facter is reset" do
    query = "select FreePhysicalMemory from Win32_OperatingSystem"
    Facter::Util::WMI.stubs(:connect).returns(connection)
    connection.expects(:execquery).with(query).returns("1048640").twice

    Facter::Util::WMI.execquery(query)
    Facter.reset
    Facter::Util::WMI.execquery(query)
  end
end
