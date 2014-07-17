#! /usr/bin/env ruby

require 'spec_helper'

describe "OS Family fact" do
  let(:os_hash) { { "name"         => "SomeOS",
                    "family"       => "SomeFamily",
                    "release"      => "1.2.3",
                    "releasemajor" => "1",
                   }
                 }

  it "should use the 'osfamily' key of the 'os' fact" do
    Facter.fact("os").stubs(:value).returns(os_hash)
    Facter.fact(:osfamily).value.should eq "SomeFamily"
  end
end
