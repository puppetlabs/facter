require 'spec_helper'
require 'facter/operatingsystem/windows'

describe Facter::Operatingsystem::Windows do
  require 'facter/util/windows'
  subject { described_class.new }

  describe "Operatingsystemrelease fact" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("windows")
    end

    {
      [5,2,3790, 1] => "XP",
      [6,0,6002, 1] => "Vista",
      [6,0,6002, 2] => "2008",
      [6,0,6002, 3] => "2008",
      [6,1,7601, 1] => "7",
      [6,1,7601, 2] => "2008 R2",
      [6,1,7601, 3] => "2008 R2",
      [6,2,9200, 1] => "8",
      [6,2,9200, 2] => "2012",
      [6,2,9200, 3] => "2012",
      [6,3,9600, 1] => "8.1",
      [6,3,9600, 2] => "2012 R2",
      [6,3,9600, 3] => "2012 R2",
      [10,0,10586, 1] => "10",     # Kernel version for Windows 10
      [10,0,14300, 2] => "Nano",   # current Nano kernel version
      [10,0,14393, 2] => "2016",
      [10,0,14393, 3] => "2016",
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}.#{os_values[1]}.#{os_values[2]}  and ProductType #{os_values[3]}" do
        os = stub('os')
        os.stubs(:[]).with(:dwMajorVersion).returns(os_values[0])
        os.stubs(:[]).with(:dwMinorVersion).returns(os_values[1])
        os.stubs(:[]).with(:dwBuildNumber).returns(os_values[2])
        os.stubs(:[]).with(:wProductType).returns(os_values[3])
        Facter::Util::Windows::Process.expects(:os_version).yields(os)
        release = subject.get_operatingsystemrelease
        expect(release).to eq expected_output
      end
    end

    {
      [5,2,3790, 2, false]   => "2003",
      [5,2,3790, 2, true] => "2003 R2",
      [5,2,3790, 3, false]   => "2003",
      [5,2,3790, 3, true] => "2003 R2",
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}.#{os_values[1]}.#{os_values[2]} and ProductType #{os_values[3]} and is_2003_r2? #{os_values[4]}" do
        os = stub('os')
        os.stubs(:[]).with(:dwMajorVersion).returns(os_values[0])
        os.stubs(:[]).with(:dwMinorVersion).returns(os_values[1])
        os.stubs(:[]).with(:dwBuildNumber).returns(os_values[2])
        os.stubs(:[]).with(:wProductType).returns(os_values[3])
        Facter::Util::Windows::Process.expects(:is_2003_r2?).returns(os_values[4])
        Facter::Util::Windows::Process.expects(:os_version).yields(os)
        release = subject.get_operatingsystemrelease
        expect(release).to eq expected_output
      end
    end

    context "Unknown Windows version" do
      before :each do
        Facter.fact(:kernelrelease).stubs(:value).returns("X.Y.ZZZZ")
      end

      it "should be kernel version value with unknown values " do
        os = stub('os')
        os.stubs(:[])
        Facter::Util::Windows::Process.expects(:os_version).yields(os)
        release = subject.get_operatingsystemrelease
        expect(release).to eq "X.Y.ZZZZ"
      end
    end
  end
end
