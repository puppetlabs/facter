require 'spec_helper'
require 'facter/operatingsystem/windows'

describe Facter::Operatingsystem::Windows do
  require 'facter/util/wmi'
  subject { described_class.new }

  describe "Operatingsystemrelease fact" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("windows")
    end

    {
      ['5.2.3790', 1] => "XP",
      ['6.0.6002', 1] => "Vista",
      ['6.0.6002', 2] => "2008",
      ['6.0.6002', 3] => "2008",
      ['6.1.7601', 1] => "7",
      ['6.1.7601', 2] => "2008 R2",
      ['6.1.7601', 3] => "2008 R2",
      ['6.2.9200', 1] => "8",
      ['6.2.9200', 2] => "2012",
      ['6.2.9200', 3] => "2012",
      ['6.3.9600', 1] => "8.1",
      ['6.3.9600', 2] => "2012 R2",
      ['6.3.9600', 3] => "2012 R2",
      ['6.4.9841', 1] => "10",     # Kernel version for Windows 10 preview. Subject to change.
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}  and ProductType #{os_values[1]}" do
        os = mock('os', :version => os_values[0], :producttype => os_values[1])
        Facter::Util::WMI.expects(:execquery).returns([os])
        release = subject.get_operatingsystemrelease
        expect(release).to eq expected_output
      end
    end

    {
      # Note: this is the kernel version for the Windows 10 technical preview,
      # which is subject to change. These tests cover any future Windows server
      # releases with a kernel version of 6.4.x, none of which have been released
      # as of October 2014.
      ['6.4.9841', 2] => "6.4.9841",
      ['6.4.9841', 3] => "6.4.9841",
    }.each do |os_values, expected_output|
      it "should be the kernel release for unknown future server releases" do
        Facter.fact(:kernelrelease).stubs(:value).returns("6.4.9841")
        os = mock('os', :version => os_values[0], :producttype => os_values[1])
        Facter::Util::WMI.expects(:execquery).returns([os])
        release = subject.get_operatingsystemrelease
        expect(release).to eq expected_output
      end
    end

    {
      ['5.2.3790', 2, ""]   => "2003",
      ['5.2.3790', 2, "R2"] => "2003 R2",
      ['5.2.3790', 3, ""]   => "2003",
      ['5.2.3790', 3, "R2"] => "2003 R2",
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}  and ProductType #{os_values[1]} and OtherTypeDescription #{os_values[2]}" do
        os = mock('os', :version => os_values[0], :producttype => os_values[1], :othertypedescription => os_values[2])
        Facter::Util::WMI.expects(:execquery).returns([os])
        release = subject.get_operatingsystemrelease
        expect(release).to eq expected_output
      end
    end

    it "reports '2003' if the WMI method othertypedescription does not exist" do
      os = mock('os', :version => '5.2.3790', :producttype => 2)
      os.stubs(:othertypedescription).raises(NoMethodError)
      Facter::Util::WMI.expects(:execquery).returns([os])
      release = subject.get_operatingsystemrelease
      expect(release).to eq "2003"
    end

    context "Unknown Windows version" do
      before :each do
        Facter.fact(:kernelrelease).stubs(:value).returns("X.Y.ZZZZ")
      end

      it "should be kernel version value with unknown values " do
        os = mock('os', :version => "X.Y.ZZZZ")
        Facter::Util::WMI.expects(:execquery).returns([os])
        release = subject.get_operatingsystemrelease
        expect(release).to eq "X.Y.ZZZZ"
      end
    end
  end
end
