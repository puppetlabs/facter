require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/manufacturer'

describe Facter::Manufacturer do
  before :each do
    Facter.clear
  end

  it "should return the system DMI table" do
    Facter::Manufacturer.should respond_to(:get_dmi_table)
  end

  it "should return nil on non-supported operating systems" do
    Facter.stubs(:value).with(:kernel).returns("SomeThing")
    Facter::Manufacturer.get_dmi_table().should be_nil
  end

  it "should parse prtdiag output on a sunfire v120" do
    Facter::Util::Resolution.stubs(:exec).returns(fixture_data(File.join("unit", "util", "manufacturer", "solaris_sunfire_v120_prtdiag")))
    Facter::Manufacturer.prtdiag_sparc_find_system_info()
    Facter.value(:manufacturer).should == "Sun Microsystems"
    Facter.value(:productname).should == "Sun Fire V120 (UltraSPARC-IIe 648MHz)"
  end

  it "should parse prtdiag output on a t5220" do
    Facter::Util::Resolution.stubs(:exec).returns(fixture_data(File.join("unit", "util", "manufacturer", "solaris_t5220_prtdiag")))
    Facter::Manufacturer.prtdiag_sparc_find_system_info()
    Facter.value(:manufacturer).should == "Sun Microsystems"
    Facter.value(:productname).should == "SPARC Enterprise T5220"
  end

  it "should not set manufacturer or productname if prtdiag output is nil" do
    # Stub kernel so we don't have windows fall through to its own mechanism
    Facter.fact(:kernel).stubs(:value).returns("SunOS")

    Facter::Util::Resolution.stubs(:exec).returns(nil)
    Facter::Manufacturer.prtdiag_sparc_find_system_info()
    Facter.value(:manufacturer).should be_nil
    Facter.value(:productname).should be_nil
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
      when "FreeBSD" then File.dirname(__FILE__) + "/../data/freebsd_dmidecode"
      when "SunOS" then File.dirname(__FILE__) + "/../data/opensolaris_smbios"
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

  it "should find information on Windows" do
    Facter.fact(:kernel).stubs(:value).returns("windows")
    require 'facter/util/wmi'

    bios = stubs 'bios'
    bios.stubs(:Manufacturer).returns("Phoenix Technologies LTD")
    bios.stubs(:Serialnumber).returns("56 4d 40 2b 4d 81 94 d6-e6 c5 56 a4 56 0c 9e 9f")

    product = stubs 'product'
    product.stubs(:Name).returns("VMware Virtual Platform")

    wmi = stubs 'wmi'
    wmi.stubs(:ExecQuery).with("select * from Win32_Bios").returns([bios])
    wmi.stubs(:ExecQuery).with("select * from Win32_Bios").returns([bios])
    wmi.stubs(:ExecQuery).with("select * from Win32_ComputerSystemProduct").returns([product])

    Facter::Util::WMI.stubs(:connect).returns(wmi)
    Facter.value(:manufacturer).should == "Phoenix Technologies LTD"
    Facter.value(:serialnumber).should == "56 4d 40 2b 4d 81 94 d6-e6 c5 56 a4 56 0c 9e 9f"
    Facter.value(:productname).should == "VMware Virtual Platform"
  end
end
