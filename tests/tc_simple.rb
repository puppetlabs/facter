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
        Facter.flush

        #if ! @oldhandles.empty?
        #    $stdin, $stdout, $stderr = @oldhandles
        #end
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
            Facter.add("testing") do
                setcode "echo yup"
            end
        }

        assert_equal("yup", Facter["testing"].value)
    end

    def test_notags
        assert_nothing_raised {
            Facter.add("testing") do
                setcode { "foo" }
            end
        }

        assert_equal("foo", Facter["testing"].value)
    end

    def test_onetruetag
        assert_nothing_raised {
            Facter.add("required") {
                setcode { "foo" }
            }
            Facter.add("testing") {
                setcode { "bar" }
                tag("required","foo")
            }
        }

        assert_equal("bar", Facter["testing"].value)
    end

    def test_onefalsetag
        assert_nothing_raised {
            Facter.add("required") {
                setcode { "foo" }
            }
            Facter.add("testing") {
                setcode { "bar" }
                tag("required","bar")
            }
        }

        assert_equal(nil, Facter["testing"].value)
    end

    # I have no idea why this test is continually failing...
    def test_recursivetags
        assert_nothing_raised {
            Facter.add("testing") {
                setcode { "bar" }
                tag("required","foo")
            }
        }
        assert_nothing_raised {
            Facter.add("required") do
                setcode { "foo" }
                tag("testing","bar")
            end
        }

        assert_equal(nil, Facter["testing"].value)
    end

    def test_multipleresolves
        assert_nothing_raised {
            Facter.add("funtest") {
                setcode { "untagged" }
            }
            Facter.add("funtest") {
                setcode { "tagged" }
                tag("operatingsystem", Facter["operatingsystem"].value)
            }
        }

        assert_equal("tagged", Facter["funtest"].value)
    end

	def test_upcase
        Facter.add("Testing") {
            setcode { "foo" }
        }
		assert_equal(
			"foo",
			Facter["Testing"].value
		)
	end

	def test_doublecall
        Facter.add("testing") {
            setcode { "foo" }
        }
		assert_equal(
			Facter["testing"].value,
			Facter["testing"].value
		)
	end

	def test_downcase
        Facter.add("testing") {
            setcode { "foo" }
        }
		assert_equal(
			"foo",
			Facter["testing"].value
		)
	end

	def test_case_insensitivity
        Facter.add("Testing") {
            setcode { "foo" }
        }
        upcase = Facter["Testing"].value
        downcase = Facter["testing"].value
		assert_equal(upcase, downcase)
	end

    def test_adding
        assert_nothing_raised() {
            Facter.add("Funtest") {
                setcode { "funtest value" }
            }
        }

        assert_equal(
            "funtest value",
            Facter["funtest"].value
        )
    end

    def test_adding2
        assert_nothing_raised() {
            Facter.add("bootest") {
                tag("operatingsystem",  Facter["operatingsystem"].value)
                setcode "echo bootest"
            }
        }

        assert_equal(
            "bootest",
            Facter["bootest"].value
        )

        assert_nothing_raised() {
            Facter.add("bahtest") {
                #obj.os = Facter["operatingsystem"].value
                #obj.release = Facter["operatingsystemrelease"].value
                tag("operatingsystem",  Facter["operatingsystem"].value)
                tag("operatingsystemrelease", 
                    Facter["operatingsystemrelease"].value)
                setcode "echo bahtest"
            }
        }

        assert_equal(
            "bahtest",
            Facter["bahtest"].value
        )

        assert_nothing_raised() {
            Facter.add("failure") {
                #obj.os = Facter["operatingsystem"].value
                #obj.release = "FakeRelease"
                tag("operatingsystem",  Facter["operatingsystem"].value)
                tag("operatingsystemrelease",  "FakeRelease")
                setcode "echo failure"
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

    def disabled_test_withnoouts
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

    def test_ldapname
        facts = {}
        assert_nothing_raised {
            Facter.each { |name, value|
                facts[name] = Facter[name]
            }
        }

        facts.each { |name, fact|
            assert(fact.ldapname, "Fact %s has no ldapname" % name)
        }
    end
end
