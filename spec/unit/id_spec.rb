#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "id fact" do

    kernel = [ 'Linux', 'Darwin', 'windows', 'FreeBSD', 'OpenBSD', 'NetBSD', 'AIX', 'HP-UX' ]

    kernel.each do |k|
        describe "with kernel reported as #{k}" do
            it "should return the current user" do
                Facter.fact(:kernel).stubs(:value).returns(k)
                Facter::Util::Config.stubs(:is_windows?).returns(k == 'windows')
                Facter::Util::Resolution.expects(:exec).once.with('whoami').returns 'bar'

                Facter.fact(:id).value.should == 'bar'
            end
        end
    end

    it "should return the current user on Solaris" do
       Facter::Util::Config.stubs(:is_windows?).returns(false)
       Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('SunOS')
       Facter::Util::Resolution.expects(:exec).once.with('/usr/xpg4/bin/id -un').returns 'bar'

       Facter.fact(:id).value.should == 'bar'
    end
end
