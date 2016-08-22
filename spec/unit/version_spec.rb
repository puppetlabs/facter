require "spec_helper"
require "facter/version"
require 'pathname'

describe "Facter.version Public API" do
  before :each do
    Facter.instance_eval do
      if @facter_version
        @facter_version = nil
      end
    end
  end

  context "without a VERSION file" do
    before :each do
      Facter.stubs(:read_version_file).returns(nil)
    end

    it "is Facter::FACTERVERSION" do
      Facter.version.should == Facter::FACTERVERSION
    end
    it "respects the version= setter" do
      Facter.version = '1.2.3'
      Facter.version.should == '1.2.3'
    end
  end

  context "with a VERSION file" do
    it "is the content of the file" do
      Facter.expects(:read_version_file).with() do |path|
        pathname = Pathname.new(path)
        pathname.basename.to_s == "VERSION"
      end.returns('1.6.14-6-gea42046')

      Facter.version.should == '1.6.14-6-gea42046'
    end
    it "respects the version= setter" do
      Facter.version = '1.2.3'
      Facter.version.should == '1.2.3'
    end
  end
end
