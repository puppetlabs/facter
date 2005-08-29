#! /usr/bin/env ruby
# $Id: $
if __FILE__ == $0
    $:.unshift '../lib'
    $facterbase = ".."
end

require 'facter'
require 'test/unit'

# add the bin directory to our search path
ENV["PATH"] += ":" + File.join($facterbase, "bin")

# and then the library directories
libdirs = $:.find_all { |dir|
    dir =~ /facter/ or dir =~ /\.\./
}
ENV["RUBYLIB"] = libdirs.join(":")

class TestFacterBin < Test::Unit::TestCase
    def setup
    end

    def teardown
    end

    def test_version
        output = nil
        assert_nothing_raised {
          output = %x{facter --version 2>&1}.chomp
        }
        print output
        assert ( output == Facter.version )
    end
end
