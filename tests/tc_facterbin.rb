#! /usr/bin/env ruby

$facterbase = File.dirname(File.dirname(__FILE__))
if $facterbase == "."
    $facterbase = ".."
end
libdir = File.join($facterbase, "lib")
$:.unshift libdir

require 'facter'
require 'test/unit'

# add the bin directory to our search path
ENV["PATH"] = File.join($facterbase, "bin") + ":" + ENV["PATH"]

# and then the library directory
ENV["RUBYLIB"] += ":" + libdir

class TestFacterBin < Test::Unit::TestCase
    def test_version
        output = nil
        assert_nothing_raised {
          output = %x{facter --version 2>&1}.chomp
        }
        assert(output == Facter.version)
    end

    def test_output
        output = nil
        assert_nothing_raised {
            output = %x{facter 2>&1}.chomp
        }

        hash = output.split("\n").inject({}) do |h, line|
            name, value = line.split(" => ")
            h[name] = value
            h
        end

        Facter.each do |name, fact|
            next if name.to_s =~ /memory/

            assert(hash.include?(name.downcase), "Did not get " + name)

            assert_equal(fact, hash[name], "%s was not equal" % name)
        end
    end

    # Verify we don't print much when they just want a single fact.
    def test_simpleoutput
        output = nil
        assert_nothing_raised {
            output = %x{facter kernel 2>&1}.chomp
        }

        assert(output !~ / => /, "Output includes the farrow thing")
    end
end

# $Id$
