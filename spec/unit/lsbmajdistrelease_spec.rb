#!/usr/bin/env ruby

require 'spec_helper'

describe "LSB distribution major release fact" do
  let(:os_hash) { { "name"          => "SomeOS",
                    "family"        => "SomeFamily",
                    "release"       => {
                      "major" => "1",
                      "minor" => "2",
                      "full"  => "1.2.3"
                    },
                    "lsb"           => {
                       "distcodename"     => "SomeCodeName",
                       "distid"           => "SomeID",
                       "distdescription"  => "SomeDesc",
                       "distrelease"      => "1.2.3",
                       "release"          => "1.2.3",
                       "majdistrelease"   => "1",
                       "minordistrelease" => "2"
                    },
                  }
                }

  it "should use the 'minordistrelease' key of the 'os' fact" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact("os").stubs(:value).returns(os_hash)
    Facter.fact(:lsbminordistrelease).value.should eq "2"
  end
end
