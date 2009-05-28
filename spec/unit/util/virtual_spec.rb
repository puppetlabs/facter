require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/virtual'

describe Facter::Util::Virtual do

    after do
        Facter.clear
    end
    it "should detect openvz" do
        FileTest.stubs(:exists?).with("/proc/vz/veinfo").returns(true)
        Facter::Util::Virtual.should be_openvz
    end

    it "should identify openvzhn when version file exists" do
        Facter::Util::Virtual.stubs(:openvz?).returns(true)
        FileTest.stubs(:exists?).with("/proc/vz/version").returns(true)
        Facter::Util::Virtual.openvz_type().should == "openvzhn"
    end

    it "should identify openvzve when no version file exists" do
        Facter::Util::Virtual.stubs(:openvz?).returns(true)
        FileTest.stubs(:exists?).with("/proc/vz/version").returns(false)
        Facter::Util::Virtual.openvz_type().should == "openvzve"
    end

    it "should identify Solaris zones when non-global zone" do
        Facter::Util::Resolution.stubs(:exec).with("/sbin/zonename").returns("somezone")
        Facter::Util::Virtual.should be_zone
    end

    it "should not identify Solaris zones when global zone" do
        Facter::Util::Resolution.stubs(:exec).with("/sbin/zonename").returns("global")
        Facter::Util::Virtual.should_not be_zone
    end

    it "should not detect vserver if no self status" do
        FileTest.stubs(:exists?).with("/proc/self/status").returns(false)
        Facter::Util::Virtual.should_not be_vserver
    end

    it "should detect vserver when vxid present in process status" do
        FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
        File.stubs(:read).with("/proc/self/status").returns("VxID: 42\n")
        Facter::Util::Virtual.should be_vserver
    end

    it "should detect vserver when s_context present in process status" do
        FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
        File.stubs(:read).with("/proc/self/status").returns("s_context: 42\n")
        Facter::Util::Virtual.should be_vserver
    end

    it "should not detect vserver when vserver flags not present in process status" do
        FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
        File.stubs(:read).with("/proc/self/status").returns("wibble: 42\n")
        Facter::Util::Virtual.should_not be_vserver
    end

end
