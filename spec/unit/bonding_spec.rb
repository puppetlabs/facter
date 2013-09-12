require "spec_helper"

describe "Bonded interface facts" do
  context "on Linux" do
    before(:each) do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      File.stubs(:exists?).with('/proc/net/bonding').returns(true)
    end

    context "with only one bonded interface" do
      before(:each) do
        Dir.stubs(:[]).with("/proc/net/bonding/*").returns("bond0")
        sample_bond0 = File.read(fixtures('unit/interfaces/','proc_net_bonding_bond0.txt'))
        Facter::Util::Resolution.stubs(:exec).with("cat bond0 2> /dev/null").returns(sample_bond0)
        Facter::Util::Resolution.stubs(:exec).with("cat /sys/class/net/bonding_masters").returns("bond0")
        Facter.collection.internal_loader.load(:bonding)
      end

      it "should enumerate a list of bonded interfaces" do
        Facter.fact(:bonding_interfaces).value.should == "bond0"
      end
    end

    context "with multiple bonded interfaces" do
      before(:each) do
        Facter::Util::Resolution.stubs(:exec).with("cat /sys/class/net/bonding_masters").returns("bond0 bond1")
        Facter.collection.internal_loader.load(:bonding)
      end

      it "should enumerate a comma seperated list of bonded interfaces" do
        Facter.fact(:bonding_interfaces).value.should == "bond0,bond1"
      end
    end
  end
end
