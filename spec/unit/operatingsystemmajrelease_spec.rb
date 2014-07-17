#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "OS Major Release fact" do
  let(:os_hash) { { "name"    => "SomeOS",
                    "family"  => "SomeFamily",
                    "release" => {
                      "major" => "1",
                      "minor" => "2",
                      "full"  => "1.2.3"
                    }
                  }
                }

  it "should use the 'major' key of the 'release' key from the 'os' fact" do
    Facter.fact(:operatingsystem).stubs(:value).returns("Amazon")
    Facter.fact("os").stubs(:value).returns(os_hash)
    Facter.fact(:operatingsystemmajrelease).value.should eq "1"
  end
end
