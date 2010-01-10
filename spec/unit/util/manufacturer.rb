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
end