require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/manufacturer'

describe Facter::Manufacturer do
    it "should return the system DMI table" do
        Facter::Manufacturer.should respond_to(:get_dmi_table)
    end

    it "should return nil on non-supported operating systems" do
        Facter.stubs(:value).with(:kernel).returns("SomeThing")
        Facter::Manufacturer.get_dmi_table().should be_nil
    end

    it "should strip white space on dmi output with spaces" do
        sample_output_file = File.dirname(__FILE__) + "/../data/linux_dmidecode_with_spaces"
        dmidecode_output = File.new(sample_output_file).read()
        Facter::Manufacturer.expects(:get_dmi_table).returns(dmidecode_output)
        Facter.fact(:kernel).stubs(:value).returns("Linux")

        query = { '[Ss]ystem [Ii]nformation' => [ { 'Product(?: Name)?:' => 'productname' } ] }

        Facter::Manufacturer.dmi_find_system_info(query)
        Facter.value(:productname).should == "MS-6754"
    end
    
    it "should handle output from smbios when run under sunos" do
        sample_output_file = File.dirname(__FILE__) + "/../data/opensolaris_smbios"
        smbios_output = File.new(sample_output_file).read()
        Facter::Manufacturer.expects(:get_dmi_table).returns(smbios_output)
        Facter.fact(:kernel).stubs(:value).returns("SunOS")

        query = { 'BIOS information' => [ { 'Release Date:' => 'reldate' } ] }

        Facter::Manufacturer.dmi_find_system_info(query)
        Facter.value(:reldate).should == "12/01/2006"
    end

    it "should not split on dmi keys containing the string Handle" do
        dmidecode_output = <<-eos
Handle 0x1000, DMI type 16, 15 bytes
Physical Memory Array
        Location: System Board Or Motherboard
        Use: System Memory
        Error Correction Type: None
        Maximum Capacity: 4 GB
        Error Information Handle: Not Provided
        Number Of Devices: 123

Handle 0x001F
        DMI type 127, 4 bytes.
        End Of Table
        eos
        Facter::Manufacturer.expects(:get_dmi_table).returns(dmidecode_output)
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        query = { 'Physical Memory Array' => [ { 'Number Of Devices:' => 'ramslots'}]}
        Facter::Manufacturer.dmi_find_system_info(query)
        Facter.value(:ramslots).should == "123"
    end

    it "should match the key in the defined section and not the first one found" do
        dmidecode_output = <<-eos
Handle 0x000C, DMI type 7, 19 bytes
Cache Information
        Socket Designation: Internal L2 Cache
        Configuration: Enabled, Socketed, Level 2
        Operational Mode: Write Back
        Location: Internal
        Installed Size: 4096 KB
        Maximum Size: 4096 KB
        Supported SRAM Types:
                Burst
        Installed SRAM Type: Burst
        Speed: Unknown
        Error Correction Type: Single-bit ECC
        System Type: Unified
        Associativity: 8-way Set-associative

Handle 0x1000, DMI type 16, 15 bytes
Physical Memory Array
        Location: System Board Or Motherboard
        Use: System Memory
        Error Correction Type: None
        Maximum Capacity: 4 GB
        Error Information Handle: Not Provided
        Number Of Devices: 2

Handle 0x001F
        DMI type 127, 4 bytes.
        End Of Table
        eos
        Facter::Manufacturer.expects(:get_dmi_table).returns(dmidecode_output)
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        query = { 'Physical Memory Array' => [ { 'Location:' => 'ramlocation'}]}
        Facter::Manufacturer.dmi_find_system_info(query)
        Facter.value(:ramlocation).should == "System Board Or Motherboard"
    end

    def find_product_name(os)
        output_file = case os
            when "FreeBSD": File.dirname(__FILE__) + "/../data/freebsd_dmidecode"
            when "SunOS"  : File.dirname(__FILE__) + "/../data/opensolaris_smbios"
            end

        output = File.new(output_file).read()
        query = { '[Ss]ystem [Ii]nformation' => [ { 'Product(?: Name)?:' => "product_name_#{os}" } ] }

        Facter.fact(:kernel).stubs(:value).returns(os)
        Facter::Manufacturer.expects(:get_dmi_table).returns(output)

        Facter::Manufacturer.dmi_find_system_info(query)

        return Facter.value("product_name_#{os}")
    end

    it "should return the same result with smbios than with dmidecode" do
        find_product_name("FreeBSD").should_not == nil
        find_product_name("FreeBSD").should == find_product_name("SunOS")
    end

end
