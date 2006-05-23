#! /usr/bin/env ruby

$facterbase = File.dirname(File.dirname(__FILE__))
libdir = File.join($facterbase, "lib")
$:.unshift libdir

require 'facter'
require 'test/unit'

# add the bin directory to our search path
ENV["PATH"] = File.join($facterbase, "bin") + ":" + ENV["PATH"]

# and then the library directory
ENV["RUBYLIB"] = libdir

class TestFacterBin < Test::Unit::TestCase
    def test_version
        output = nil
        assert_nothing_raised {
          output = %x{facter --version 2>&1}.chomp
        }
        assert(output == Facter.version)
    end
end

# $Id$
