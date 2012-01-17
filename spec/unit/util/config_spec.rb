#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/config'

describe Facter::Util::Config do
  describe "is_windows? function" do
    it "should detect windows if RbConfig returns a windows OS" do
      host_os = ["mswin","win32","dos","mingw","cygwin"]
      host_os.each do |h|
        RbConfig::CONFIG.expects(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_windows?.should be_true
      end
    end

    it "should not detect windows if RbConfig returns a non-windows OS" do
      host_os = ["darwin","linux"]
      host_os.each do |h|
        RbConfig::CONFIG.expects(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_windows?.should be_false
      end
    end
  end
end
