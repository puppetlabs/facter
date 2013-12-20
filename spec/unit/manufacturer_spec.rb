#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'
require 'facter/util/manufacturer'

describe "Hardware manufacturer facts" do
  
  describe "on OS'es without DMI support" do

    it "no DMI facts should be reported" do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      Facter.fact(:boardmanufacturer).should == nil
      Facter.fact(:boardproductname).should == nil
      Facter.fact(:boardserialnumber).should == nil
      Facter.fact(:bios_vendor).should == nil
      Facter.fact(:bios_version).should == nil
      Facter.fact(:bios_release_date).should == nil
      Facter.fact(:type).should == nil
    end

  end
  
  describe "on OS'es with DMI support" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      dmidecode_output = <<-eos
Handle 0x0000, DMI type 0, 24 bytes
BIOS Information
        Vendor: Dell Inc.
        Version: 1.2.5
        Release Date: 03/16/2011
        Address: 0xF0000
        Runtime Size: 64 kB
        ROM Size: 4096 kB
        Characteristics:
                ISA is supported
                PCI is supported
                PNP is supported
                BIOS is upgradeable
                BIOS shadowing is allowed
                Boot from CD is supported
                Selectable boot is supported
                EDD is supported
                8042 keyboard services are supported (int 9h)
                Serial services are supported (int 14h)
                CGA/mono video services are supported (int 10h)
                ACPI is supported
                USB legacy is supported
                BIOS boot specification is supported
                Function key-initiated network boot is supported
                Targeted content distribution is supported
        BIOS Revision: 1.2

Handle 0x0100, DMI type 1, 27 bytes
System Information
        Manufacturer: Dell Inc.
        Product Name: PowerEdge R515
        Version: Not Specified
        Serial Number: ABCD124
        UUID: 1A2B3456-7890-1A23-4567-B8C91D123456
        Wake-up Type: Power Switch
        SKU Number: Not Specified
        Family: Not Specified

Handle 0x0200, DMI type 2, 9 bytes
Base Board Information
        Manufacturer: Dell Inc.
        Product Name: 03X0MN
        Version: A03
        Serial Number: ..AB1234567B1234.
        Asset Tag: Not Specified

Handle 0x0300, DMI type 3, 21 bytes
Chassis Information
        Manufacturer: Dell Inc.
        Type: Rack Mount Chassis
        Lock: Present
        Version: Not Specified
        Serial Number: ABCD124
        Asset Tag: Not Specified
        Boot-up State: Safe
        Power Supply State: Safe
        Thermal State: Safe
        Security Status: Unknown
        OEM Information: 0x00000000
        Height: 2 U
        Number Of Power Cords: Unspecified
        Contained Elements: 0

Handle 0x7F00, DMI type 127, 4 bytes
End Of Table
      eos
      Facter::Manufacturer.stubs(:get_dmi_table).returns(dmidecode_output)
    end
    
    it "should report the correct details from the DMI query" do
      Facter.fact(:manufacturer).value.should == "Dell Inc."
      Facter.fact(:boardmanufacturer).value.should == "Dell Inc."
      Facter.fact(:boardproductname).value.should == "03X0MN"
      Facter.fact(:boardserialnumber).value.should == "..AB1234567B1234."
      Facter.fact(:bios_vendor).value.should == "Dell Inc."
      Facter.fact(:bios_version).value.should == "1.2.5"
      Facter.fact(:bios_release_date).value.should == "03/16/2011"
      Facter.fact(:manufacturer).value.should == "Dell Inc."
      Facter.fact(:productname).value.should == "PowerEdge R515"
      Facter.fact(:serialnumber).value.should == "ABCD124"
      Facter.fact(:type).value.should == "Rack Mount Chassis"
      Facter.fact(:productname).value.should_not == Facter.fact(:boardproductname).value
      Facter.fact(:serialnumber).value.should_not == Facter.fact(:boardserialnumber).value
    end
    
  end
  
end
