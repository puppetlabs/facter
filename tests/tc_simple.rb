#! /usr/bin/env ruby
# $Id$
#     
if __FILE__ == $0 # Make this library first!
    $:.unshift '../lib'
end

require 'test/unit'
require 'facter'

if __FILE__ == $0
    Facter.debugging(true)
end

class TestFacter < Test::Unit::TestCase
    def setup
        Facter.load
    end

    def teardown
        # clear out the list of facts, so we start fresh for every test
        Facter.reset

        if ! @oldhandles.empty?
            $stdin, $stdout, $stderr = @oldhandles
        end
    end

    def test_version 
        #Could match /[0-9.]+/
        #Strict match: /^[0-9]+(\.[0-9]+)*$/
        #ok: 1.0.0 1.0 1
        #notok: 1..0 1. .1 1a
        assert(Facter.version =~ /^[0-9]+(\.[0-9]+)*$/ )
    end

    def test_notags_sh
        assert_nothing_raised {
            Facter["testing"].add { |fact|
                fact.code = "echo yup"
            }
        }

        assert_equal("yup", Facter["testing"].value)
    end

    def test_notags
        assert_nothing_raised {
            Facter["testing"].add { |fact|
                fact.code = proc { "foo" }
            }
        }

        assert_equal("foo", Facter["testing"].value)
    end

    def test_onetruetag
        assert_nothing_raised {
            Facter["required"].add { |fact|
                fact.code = proc { "foo" }
            }
            Facter["testing"].add { |fact|
                fact.code = proc { "bar" }
                fact.tag("required","=","foo")
            }
        }

        assert_equal("bar", Facter["testing"].value)
    end

    def test_onefalsetag
        assert_nothing_raised {
            Facter["required"].add { |fact|
                fact.code = proc { "foo" }
            }
            Facter["testing"].add { |fact|
                fact.code = proc { "bar" }
                fact.tag("required","=","bar")
            }
        }

        assert_equal(nil, Facter["testing"].value)
    end

    def test_recursivetags
        assert_nothing_raised {
            Facter["required"].add { |fact|
                fact.code = proc { "foo" }
                fact.tag("testing","=","foo")
            }
            Facter["testing"].add { |fact|
                fact.code = proc { "bar" }
                fact.tag("required","=","foo")
            }
        }

        assert_equal(nil, Facter["testing"].value)
    end

    def test_multipleresolves
        assert_nothing_raised {
            Facter["funtest"].add { |fact|
                fact.code = proc { "untagged" }
            }
            Facter["funtest"].add { |fact|
                fact.code = proc { "tagged" }
                fact.tag("operatingsystem","=", Facter["operatingsystem"].value)
            }
        }

        assert_equal("tagged", Facter["funtest"].value)
    end

	def test_osname
		assert_equal(
            %x{uname -s}.chomp,
			Facter["operatingsystem"].value
		)
	end

	def test_osrel
		assert_equal(
            %x{uname -r}.chomp,
			Facter["operatingsystemrelease"].value
		)
	end

	def test_hostname
		assert_equal(
            %x{hostname}.chomp.sub(/\..+/,''),
			Facter["hostname"].value
		)
	end

	def test_upcase
        Facter["Testing"].add { |fact|
            fact.code = proc { "foo" }
        }
		assert_equal(
			"foo",
			Facter["Testing"].value
		)
	end

	def test_doublecall
        Facter["testing"].add { |fact|
            fact.code = proc { "foo" }
        }
		assert_equal(
			Facter["testing"].value,
			Facter["testing"].value
		)
	end

	def test_downcase
        Facter["testing"].add { |fact|
            fact.code = proc { "foo" }
        }
		assert_equal(
			"foo",
			Facter["testing"].value
		)
	end

	def test_case_insensitivity
        Facter["Testing"].add { |fact|
            fact.code = proc { "foo" }
        }
        upcase = Facter["Testing"].value
        downcase = Facter["testing"].value
		assert_equal(upcase, downcase)
	end

    def test_adding
        assert_nothing_raised() {
            Facter["Funtest"].add { |obj|
                obj.code = proc { return "funtest value" }
            }
        }

        assert_equal(
            "funtest value",
            Facter["funtest"].value
        )

        assert_nothing_raised() {
            code = proc { return "yaytest value" }
            block = proc { |obj| obj.code = code }
            Facter["Yaytest"].add(&block)
        }

        assert_equal(
            "yaytest value",
            Facter["yaytest"].value
        )
    end

    def test_comparison
        assert(
            %x{uname -s}.chomp == Facter["operatingsystem"].value
        )
        assert(
            %x{hostname}.chomp.sub(/\..+/,'') == Facter["hostname"].value
        )
    end

    def test_adding2
        assert_nothing_raised() {
            Facter["bootest"].add { |obj|
                obj.tag("operatingsystem", "=", Facter["operatingsystem"].value)
                obj.code = "echo bootest"
            }
        }

        assert_equal(
            "bootest",
            Facter["bootest"].value
        )

        assert_nothing_raised() {
            Facter["bahtest"].add { |obj|
                #obj.os = Facter["operatingsystem"].value
                #obj.release = Facter["operatingsystemrelease"].value
                obj.tag("operatingsystem", "=", Facter["operatingsystem"].value)
                obj.tag("operatingsystemrelease", "=",
                    Facter["operatingsystemrelease"].value)
                obj.code = "echo bahtest"
            }
        }

        assert_equal(
            "bahtest",
            Facter["bahtest"].value
        )

        assert_nothing_raised() {
            Facter["failure"].add { |obj|
                #obj.os = Facter["operatingsystem"].value
                #obj.release = "FakeRelease"
                obj.tag("operatingsystem", "=", Facter["operatingsystem"].value)
                obj.tag("operatingsystemrelease", "=", "FakeRelease")
                obj.code = "echo failure"
            }
        }

        assert_equal(
            nil,
            Facter["failure"].value
        )
    end

    def test_distro
        if Facter["operatingsystem"] == "Linux"
            assert(Facter["Distro"])
        end
    end

    def test_each
        list = {}
        assert_nothing_raised {
            Facter.each { |name,fact|
                list[name] = fact
            }
        }

        list.each { |name,value|
            assert(value.class != Facter)
            assert(name)
            assert(value)
        }
    end

    def test_withnoouts
        @oldhandles = []
        @oldhandles << $stdin.dup
        $stdin.reopen "/dev/null"
        @oldhandles << $stdout.dup
        $stdout.reopen "/dev/null", "a"
        @oldhandles << $stderr.dup
        $stderr.reopen $stdout

        assert_nothing_raised {
            Facter.each { |name,fact|
                list[name] = fact
            }
        }
        $stdin, $stdout, $stderr = @oldhandles
    end
end
