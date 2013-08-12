require 'spec_helper'

describe "gid fact" do

  describe "on systems with id" do
    it "should return the current group" do
      Facter::Util::Resolution.expects(:which).with('id').returns(true)
      Facter::Util::Resolution.expects(:exec).once.with('id -ng').returns 'bar'

      Facter.fact(:gid).value.should == 'bar'
    end
  end

  describe "on systems without id" do
    it "is not supported" do
      Facter::Util::Resolution.expects(:which).with('id').returns(false)

      Facter.fact(:gid).value.should == nil
    end
  end

end
