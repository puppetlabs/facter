#! /usr/bin/env ruby

require 'spec_helper'

describe "Operating System fact" do
  let(:os_hash) { { "name"         => "SomeOS",
                    "family"       => "SomeFamily",
                    "release"      => "1.2.3",
                    "releasemajor" => "1",
                   }
                 }

  it "should use the 'operatingsystem' key from the 'os' fact" do
    Facter.fact("os").stubs(:value).returns(os_hash)
    Facter.fact(:operatingsystem).value.should eq "SomeOS"
  end
end
