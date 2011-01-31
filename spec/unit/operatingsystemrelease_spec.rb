#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "Operating System Release fact" do

    before do
        Facter.clear
    end

    after do
        Facter.clear
    end

    test_cases = {
        "CentOS" => "/etc/redhat-release",
        "RedHat" => "/etc/redhat-release",
        "Fedora" => "/etc/fedora-release",
        "MeeGo"  => "/etc/meego-release",
        "OEL"    => "/etc/enterprise-release",
        "oel"    => "/etc/enterprise-release",
        "OVS"    => "/etc/ovs-release",
        "ovs"    => "/etc/ovs-release"
    }

    test_cases.each do |system, file|
        describe "with operatingsystem reported as #{system.inspect}" do
            it "should read the #{file.inspect} file" do
                Facter.fact(:operatingsystem).stubs(:value).returns(system)

                File.expects(:open).with(file, "r").at_least(1)

                Facter.fact(:operatingsystemrelease).value
            end
        end
    end
end
