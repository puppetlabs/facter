#! /usr/bin/env ruby

require 'spec_helper'

describe "id fact" do
  include FacterSpec::ConfigHelper

  kernel = [ 'Linux', 'Darwin', 'windows', 'FreeBSD', 'OpenBSD', 'NetBSD', 'AIX', 'HP-UX' ]

  kernel.each do |k|
    describe "with kernel reported as #{k}" do
      it "should return the current user" do
        given_a_configuration_of(:is_windows => k == 'windows')
        Facter.fact(:kernel).stubs(:value).returns(k)
        Facter::Core::Execution.expects(:execute).once.with('whoami', anything).returns 'bar'

        Facter.fact(:id).value.should == 'bar'
      end
    end
  end

  it "should return the current user on Solaris" do
    given_a_configuration_of(:is_windows => false)
    Facter.fact(:kernel).stubs(:value).returns 'SunOS'
    Facter::Core::Execution.expects(:execute).once.with('/usr/xpg4/bin/id -un', anything).returns 'bar'

    Facter.fact(:id).value.should == 'bar'
  end
end
