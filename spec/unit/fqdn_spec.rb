#! /usr/bin/env ruby

require 'spec_helper'

describe "fqdn fact" do
  # Prefer hostname -f if available on systems that support it.
  # (Pass Strings, not Symbols, or else :kernel-value comparison fails
  # on ruby 1.8.7.)
  ["darwin", "freebsd", "linux"].each do |platform|
    describe "on #{platform}" do
      before do
        Facter.fact(:kernel).stubs(:value).returns(platform)
      end

      it "should use the hostname -f command" do
        Facter::Core::Execution.stubs(:exec).with("hostname -f 2> /dev/null").returns("#{platform}.bananas.tld")
        Facter.fact(:hostname).stubs(:value).returns("bananas-#{platform}")
        Facter.fact(:domain).stubs(:value).returns("bananas.tld")
        Facter.fact(:fqdn).value.should == "#{platform}.bananas.tld"  # not bananas-#{platform}.bananas.tld
      end
    end
  end

  # On platforms other than the ones above, behave as originally:
  # concatenate hostname and domain.
  describe "on Windows" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Windows")
    end

    it "should concatenate hostname and domain" do
      Facter.fact(:hostname).stubs(:value).returns("bananas-windows")
      Facter.fact(:domain).stubs(:value).returns("bananas.tld")
      Facter.fact(:fqdn).value.should == "bananas-windows.bananas.tld"
    end
    it "should return hostname when domain is nil" do
      Facter.fact(:hostname).stubs(:value).returns("bananas-windows")
      Facter.fact(:domain).stubs(:value).returns(nil)
      Facter.fact(:fqdn).value.should == "bananas-windows"
    end
  end
end
