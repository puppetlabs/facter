#!/usr/bin/env ruby

$facterbase = File.dirname(File.dirname(__FILE__))
if $facterbase == "."
    $facterbase = ".."
end
libdir = File.join($facterbase, "lib")
$:.unshift libdir

require 'test/unit'
require 'facter'
require 'fileutils'

if __FILE__ == $0
    Facter.debugging(true)
end

class TestFacter < Test::Unit::TestCase
    def tearhook(&block)
        @tearhooks << block
    end

    def setup
        Facter.loadfacts

        @tmpfiles = []
        @tearhooks = []
    end

    def teardown
        # clear out the list of facts, so we start fresh for every test
        Facter.clear

        @tmpfiles.each do |file|
            if FileTest.exists?(file)
                system("rm -rf %s" % file)
            end
        end
    end

    def test_version 
        #Could match /[0-9.]+/
        #Strict match: /^[0-9]+(\.[0-9]+)*$/
        #ok: 1.0.0 1.0 1
        #notok: 1..0 1. .1 1a
        assert(Facter.version =~ /^[0-9]+(\.[0-9]+)*$/ )
    end

    def test_noconfines_sh
        assert_nothing_raised {
            Facter.add("testing") do
                setcode "echo yup"
            end
        }

        assert_equal("yup", Facter["testing"].value)
    end

    def test_noconfines
        assert_nothing_raised {
            Facter.add("testing") do
                setcode { "foo" }
            end
        }

        assert_equal("foo", Facter["testing"].value)
    end

    def test_onetrueconfine
        assert_nothing_raised {
            Facter.add("required") {
                setcode { "foo" }
            }
            Facter.add("testing") {
                setcode { "bar" }
                confine("required","foo")
            }
        }

        assert_equal("bar", Facter["testing"].value)
    end

    def test_onefalseconfine
        assert_nothing_raised {
            Facter.add("required") {
                setcode { "foo" }
            }
            Facter.add("testing") {
                setcode { "bar" }
                confine("required","bar")
            }
        }

        assert_equal(nil, Facter["testing"].value)
    end

    def test_recursiveconfines
        # This will try to autoload "required", which will fail, so the
        # fact will be marked as unsuitable.
        assert_nothing_raised {
            Facter.add("testing") {
                setcode { "bar" }
                confine("required","foo")
            }
        }
        assert_nothing_raised {
            Facter.add("required") do
                setcode { "foo" }
                confine("testing","bar")
            end
        }

        assert_equal(nil, Facter["testing"].value)
    end

    def test_multipleresolves
        assert_nothing_raised {
            Facter.add("funtest") {
                setcode { "unconfineged" }
            }
            Facter.add("funtest") {
                setcode { "confineged" }
                confine("operatingsystem", Facter["operatingsystem"].value)
            }
        }

        assert_equal("confineged", Facter["funtest"].value)
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
                confine("operatingsystem",  Facter["operatingsystem"].value)
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
                confine("operatingsystem",  Facter["operatingsystem"].value)
                confine("operatingsystemrelease", 
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
                confine("operatingsystem",  Facter["operatingsystem"].value)
                confine("operatingsystemrelease",  "FakeRelease")
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

    def test_hash
        hash = nil
        assert_nothing_raised {
            hash = Facter.to_hash
        }

        assert_instance_of(Hash, hash)

        hash.each do |name, value|
            assert_instance_of(String, name)
            assert_instance_of(String, value, "%s's value is not a string" % name)
        end
    end

    # Verify we can call retrieve facts as methods
    def test_factfunction
        val = nil
        assert_nothing_raised {
            val = Facter.operatingsystem
        }

        assert_equal(Facter["operatingsystem"].value, val)

        assert_raise(NoMethodError) { Facter.nosuchfact }
    end

    def test_versionfacts
        assert_nothing_raised {
            assert(Facter.facterversion, "Could not get facter version")
            assert(Facter.rubyversion, "Could not get ruby version")
        }
    end

    # Verify we autoload everything from the start.
    def test_initautoloading
        dir = "/tmp/facterloading"
        @tmpfiles << dir
        Dir.mkdir(dir)
        Dir.mkdir(File.join(dir, "facter"))
        $: << dir

        # Make sure we don't have a value right now.
        assert_raise(NoMethodError) do
            Facter.initautoloadfact
        end
        assert_nil(Facter["initautoloadfact"])

        # Make our file
        val = "autoloadedness"
        File.open(File.join(dir, "facter", "initautoloadfact.rb"), "w") do |file|
            file.puts %{
Facter.add("InitAutoloadFact") do
    setcode { "#{val}" }
end
}
        end

        # Now reset and reload
        Facter.reset
        Facter.flush

        # And load
        assert_nothing_raised {
            Facter.loadfacts
        }

        hash = nil
        assert_nothing_raised {
            hash = Facter.to_hash
        }

        assert(hash.include?("initautoloadfact"), "Did not load fact at startup")
        assert_equal(val, hash["initautoloadfact"], "Did not get correct value")
    end

    def test_localfacts
        dir = "/tmp/localloading"
        @tmpfiles << dir
        Dir.mkdir(dir)
        Dir.mkdir(File.join(dir, "facter"))
        $: << dir
        
        Dir.mkdir(File.join(dir, "facterlib1"))
        Dir.mkdir(File.join(dir, "facterlib2"))
        ENV['FACTERLIB'] = "#{dir}/facterlib1:#{dir}/facterlib2"
        
        # Make sure we don't have a value right now, for both the localfact
        # and the facterlib fact.
        assert_raise(NoMethodError) do
            Facter.localfact
        end
        assert_nil(Facter["localfact"])
        
        assert_raise(NoMethodError) do
            Facter.facterlibfact
        end
        assert_nil(Facter["faterlibfact"])
        
        assert_raise(NoMethodError) do
            Facter.facterlibfact2
        end
        assert_nil(Facter["faterlibfact2"])

        # Make our files
        val = "localness"
        File.open(File.join(dir, "facter", "local.rb"), "w") do |file|
            file.puts %{
Facter.add("LocalFact") do
    setcode { "#{val}" }
end
}
        end
        File.open(File.join(dir, "facterlib1", "facterlibfact.rb"), "w") do |file|
            file.puts %{
Facter.add("facterlibfact") do
    setcode { "#{val}" }
end
}
        end
        File.open(File.join(dir, "facterlib2", "facterlibfact2.rb"), "w") do |file|
            file.puts %{
Facter.add("facterlibfact2") do
    setcode { "#{val}" }
end
}
        end

        # Now reset and reload
        Facter.reset
        Facter.flush

        # And load
        assert_nothing_raised {
            Facter.loadfacts
        }

        hash = nil
        assert_nothing_raised {
            hash = Facter.to_hash
        }
        
        assert(hash.include?("localfact"), "Did not load fact at startup")
        assert(hash.include?("facterlibfact"), "Did not load fact from FACTERLIB")
        assert(hash.include?("facterlibfact2"), "Did not load fact from multiple FACTERLIBs")
        assert_equal(val, hash["localfact"], "Did not get correct value")
        assert_equal(val, hash["facterlibfact"], "Did not get correct value from FACTERLIB fact")
        assert_equal(val, hash["facterlibfact2"], "Did not get correct value from multiple FACTERLIB facts")
    end

    def test_stupidchdirring
        dir = "/tmp/localloading"
        @tmpfiles << dir
        Dir.mkdir(dir)
        $: << dir

        # Make our file
        val = "localness"
        File.open(File.join(dir, "facter"), "w") do |file|
            file.puts %{
some random stuff
}
        end

        assert_nothing_raised do
            Facter.loadfacts
        end
    end

    def test_confine_as_array_and_hash
        assert_nothing_raised {
            Facter.add("myfact") do
                confine "kernel", Facter.kernel
                setcode do "yep" end
            end
        }

        assert_equal("yep", Facter.myfact, "Did not get confineged goal")

        # now try it as a hash
        assert_nothing_raised {
            Facter.add("hashfact") do
                confine "kernel" => Facter.kernel
                setcode do "hashness" end
            end
        }

        assert_equal("hashness", Facter.hashfact, "Did not get confineged goal")

        # now with multiple values
        assert_nothing_raised {
            Facter.add("hashfact2") do
                confine :kernel => ["nosuchkernel", Facter.kernel]
                setcode do "multihash" end
            end
        }

        assert_equal("multihash", Facter.hashfact2, "Did not get multivalue confine")

    end

    def test_strings_or_symbols
        assert_nothing_raised {
            Facter.add("symbol1") do
                confine :kernel => Facter.kernel
                setcode do "yep1" end
            end
        }

        assert_equal("yep1", Facter.symbol1, "Did not get symbol fact")
    end

    def test_confine_case_insensitivity
        assert_nothing_raised {
            Facter.add :casetest1 do
                confine :kernel => Facter.kernel.downcase
                setcode do "yep1" end
            end
        }

        assert_equal("yep1", Facter.casetest1, "Did not get case test 1")

        assert_nothing_raised {
            Facter.add :casetest2 do
                confine :kernel => Facter.kernel.upcase
                setcode do "yep2" end
            end
        }

        assert_equal("yep2", Facter.casetest2, "Did not get case test 1")
    end

    def test_tags
        assert_nothing_raised {
            Facter.add :tagtest do
                setcode do "yep1" end
                tag :system, :performance
            end

            # Now add another resolution mechanism with overlapping tags
            Facter.add :tagtest do
                setcode do "yep2" end
                tag :puppet, :performance
            end

            # Finally, one that's only got the performance tag
            Facter.add :othertag do
                setcode do "nope" end
                tag :performance
            end
        }

        tags = nil
        assert_nothing_raised {
            tags = Facter[:tagtest].tags
        }
        [:puppet, :performance, :system].each do |t|
            assert(tags.include?(t), "Did not get tag %s" % t)
        end

        hash = nil
        assert_nothing_raised {
            hash = Facter.to_hash(:puppet, :system)
        }

        assert(hash.include?("tagtest"), "Did not get tagged fact")
        assert(! hash.include?("othertag"), "Got incorrectly tagged fact")
    end

    if Facter.kernel == "Linux"
    def test_memoryonlinux
        assert_nothing_raised {
            assert(Facter.memorysize, "Did not get memory")
        }
    end

    def test_processor_on_linux
        assert_nothing_raised {
            assert(Facter.processorcount, "Did not get proc count")
            assert(Facter.processor0, "Did not get proc 0")
        }
    end
    end

    def test_factquestion
        kernel = Facter.kernel
        assert_nothing_raised {
            assert(Facter.kernel?(kernel.downcase), "Kernel did not match")
            assert(Facter.kernel?(kernel.upcase), "Upcase kernel did not match")
            assert(Facter.kernel?(kernel.intern), "Symbol kernel did not match")
            assert(! Facter.kernel?("nosuchkernel"), "Fake kernel matched")
        }
    end

    # Make sure that facter doesn't fail when it gets bad files.
    def test_ignore_bad_files
        # Create a broken file
        dir = "/tmp/factertest-brokenfile"
        @tmpfiles << dir
        libdir = File.join(dir, "facter")

        FileUtils.mkdir_p(libdir)

        $: << libdir
        tearhook { $:.delete libdir }

        file = File.join(libdir, "file.rb")


        File.open(file, "w") do |f|
            f.puts "asdflkjaeflkj23rljadflkjasdfuhasd8;;lkjadsf;j24iojlkajsdf"
        end

        assert_nothing_raised {
            Facter.loadfacts()
        }


    end

    def test_env_facts
        value = "a fact"

        %w{FACTER_ENVNESS facter_envness facterenvness facter_envness}.each do |var|
            ENV[var] = value

            assert_nothing_raised {
                Facter.loadfacts()
            }

            assert(Facter["envness"], "Did not get env fact")

            assert_equal(value, Facter["envness"].value,
                "Did not get value correctly")

            resp = nil
            assert_nothing_raised {
                resp = Facter.envness
            }

            assert_equal(value, resp)
            ENV.delete(var)
            Facter.clear
        end
    end
    
    # Make sure that ssh keys only include the key, not the comment or the type.
    def test_ssh_keys
        %w{rsa dsa}.each do |type|
            key = Facter.value("ssh#{type}key")
            assert(key, "did not retrieve %s key" % type)
            assert(key !~ /\s/, "%s key contains whitespace" % type)
        end
    end
end

# $Id$
