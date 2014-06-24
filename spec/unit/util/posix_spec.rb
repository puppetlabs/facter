require 'spec_helper'
require 'facter/util/posix'

describe Facter::Util::POSIX do
  describe "retrieving values via sysctl" do
    it "returns the result of the sysctl command" do
      Facter::Util::Resolution.expects(:exec).with("sysctl -n hw.pagesize 2>/dev/null").returns("somevalue")
      expect(described_class.sysctl("hw.pagesize")).to eq "somevalue"
    end
  end
end
