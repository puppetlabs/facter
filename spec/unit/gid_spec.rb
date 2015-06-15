require 'spec_helper'

describe "gid fact" do

  describe "on non-SunOS systems with id" do
    it "should return the current group" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter::Core::Execution.expects(:which).with('id').returns(true)
      Facter::Core::Execution.expects(:exec).once.with('id -ng').returns 'bar'

      Facter.fact(:gid).value.should == 'bar'
    end
  end

  describe "on non-SunOS systems without id" do
    it "is not supported" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter::Core::Execution.expects(:which).with('id').returns(false)

      Facter.fact(:gid).value.should == nil
    end
  end

  describe "on SunOS systems with /usr/xpg4/bin/id" do
    it "should return the current group" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      File.expects(:exist?).with('/usr/xpg4/bin/id').returns true
      Facter::Core::Execution.expects(:exec).with('/usr/xpg4/bin/id -ng').returns 'bar'

      Facter.fact(:gid).value.should == 'bar'
    end
  end

  describe "on SunOS systems without /usr/xpg4/bin/id" do
    it "is not supported" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      File.expects(:exist?).with('/usr/xpg4/bin/id').returns false

      Facter.fact(:gid).value.should == nil
    end
  end

  describe "on windows systems" do
    it "is not supported" do
      Facter.fact(:kernel).stubs(:value).returns("windows")
      Facter::Core::Execution.expects(:which).with('id').returns(true)

      Facter.fact(:gid).value.should == nil
    end
  end
end
