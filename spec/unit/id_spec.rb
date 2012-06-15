#!/usr/bin/env rspec

require 'spec_helper'

describe "id fact" do
  include FacterSpec::ConfigHelper

  kernel = [ 'Linux', 'Darwin', 'windows', 'FreeBSD', 'OpenBSD', 'NetBSD', 'AIX', 'HP-UX' ]

  kernel.each do |k|
    describe "with kernel reported as #{k}" do
      it "should return the current user" do
        given_a_configuration_of(:is_windows => k == 'windows')
        Facter.fact(:kernel).stubs(:value).returns(k)
        Facter::Util::Resolution.expects(:exec).once.with('whoami').returns 'bar'

        Facter.fact(:id).value.should == 'bar'
      end
    end
  end

  it "should return the current user on Solaris" do
    given_a_configuration_of(:is_windows => false)
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('SunOS')
    Facter::Util::Resolution.expects(:exec).once.with('/usr/xpg4/bin/id -un').returns 'bar'

    Facter.fact(:id).value.should == 'bar'
  end
end
