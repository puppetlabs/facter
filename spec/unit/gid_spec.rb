require 'spec_helper'

describe "gid fact" do

  describe "on systems with id" do
    it "should return the current group" do
      Facter::Core::Execution.expects(:which).with('id').returns(true)
      Facter::Core::Execution.expects(:exec).once.with('id -ng').returns 'bar'

      Facter.fact(:gid).value.should == 'bar'
    end
  end

  describe "on systems without id" do
    it "is not supported" do
      Facter::Core::Execution.expects(:which).with('id').returns(false)

      Facter.fact(:gid).value.should == nil
    end
  end

end
