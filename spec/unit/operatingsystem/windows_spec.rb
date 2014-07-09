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
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}  and ProductType #{os_values[1]}" do
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
