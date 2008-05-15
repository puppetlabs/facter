#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/loader'

# Make sure we have a Puppet constant, so we can test
# loading Puppet facts.
unless defined?(Puppet)
    class Puppet; end
end

describe Facter::Util::Loader do
    def with_env(values)
        old = {}
        values.each do |var, value|
            if old_val = ENV[var]
                old[var] = old_val
            end
            ENV[var] = value
        end
        yield
        values.each do |var, value|
            if old.include?(var)
                ENV[var] = old[var]
            else
                ENV.delete(var)
            end
        end
    end

    it "should have a method for loading individual facts by name" do
        Facter::Util::Loader.new.should respond_to(:load)
    end

    it "should have a method for loading all facts" do
        Facter::Util::Loader.new.should respond_to(:load_all)
    end

    it "should have a method for returning directories containing facts" do
        Facter::Util::Loader.new.should respond_to(:search_path)
    end

    describe "when determining the search path" do
        before do
            @loader = Facter::Util::Loader.new
            @settings = mock 'settings'
            @settings.stubs(:value).returns "/eh"
            Puppet.stubs(:settings).returns @settings
        end

        it "should include the facter subdirectory of all paths in ruby LOAD_PATH" do
            dirs = $LOAD_PATH.collect { |d| File.join(d, "facter") }
            paths = @loader.search_path

            dirs.each do |dir|
                paths.should be_include(dir)
            end
        end

        describe "and the FACTERLIB environment variable is set" do
            it "should include all paths in FACTERLIB" do
                with_env "FACTERLIB" => "/one/path:/two/path" do
                    paths = @loader.search_path
                    %w{/one/path /two/path}.each do |dir|
                        paths.should be_include(dir)
                    end
                end
            end
        end

        describe "and the Puppet libraries are loaded" do
            it "should include the factdest setting" do
                @settings.expects(:value).with(:factdest).returns "/my/facts"
                @loader.search_path.should be_include("/my/facts")
            end

            it "should include the facter subdirectory of the libdir setting" do
                @settings.expects(:value).with(:libdir).returns "/lib/dir"
                @loader.search_path.should be_include("/lib/dir/facter")
            end
        end
    end

    describe "when loading facts" do
        before do
            @loader = Facter::Util::Loader.new
            @loader.stubs(:search_path).returns []
        end

        it "should load values from the matching environment variable if one is present" do
            Facter.expects(:add).with("testing")

            with_env "facter_testing" => "yayness" do
                @loader.load(:testing)
            end
        end
        
        it "should load any files in the search path with names matching the fact name" do
            @loader.expects(:search_path).returns %w{/one/dir /two/dir}
            FileTest.stubs(:exist?).returns false
            FileTest.expects(:exist?).with("/one/dir/testing.rb").returns true
            FileTest.expects(:exist?).with("/two/dir/testing.rb").returns true

            Kernel.expects(:load).with("/one/dir/testing.rb")
            Kernel.expects(:load).with("/two/dir/testing.rb")

            @loader.load(:testing)
        end

        it "should load any ruby files in directories matching the fact name in the search path" do
            @loader.expects(:search_path).returns %w{/one/dir}
            FileTest.stubs(:exist?).returns false
            FileTest.expects(:directory?).with("/one/dir/testing").returns true

            Dir.expects(:entries).with("/one/dir/testing").returns %w{two.rb}

            Kernel.expects(:load).with("/one/dir/testing/two.rb")

            @loader.load(:testing)
        end

        it "should not load files that don't end in '.rb'" do
            @loader.expects(:search_path).returns %w{/one/dir}
            FileTest.stubs(:exist?).returns false
            FileTest.expects(:directory?).with("/one/dir/testing").returns true

            Dir.expects(:entries).with("/one/dir/testing").returns %w{one}

            Kernel.expects(:load).never

            @loader.load(:testing)
        end
    end

    describe "when loading all facts" do
        before do
            @loader = Facter::Util::Loader.new
            @loader.stubs(:search_path).returns []
        end

        it "should load all files in all search paths" do
            @loader.expects(:search_path).returns %w{/one/dir /two/dir}

            Dir.expects(:entries).with("/one/dir").returns %w{a.rb b.rb}
            Dir.expects(:entries).with("/two/dir").returns %w{c.rb d.rb}

            %w{/one/dir/a.rb /one/dir/b.rb /two/dir/c.rb /two/dir/d.rb}.each { |f| Kernel.expects(:load).with(f) }

            @loader.load_all
        end

        it "should load all files in all subdirectories in all search paths" do
            @loader.expects(:search_path).returns %w{/one/dir /two/dir}

            Dir.expects(:entries).with("/one/dir").returns %w{a}
            Dir.expects(:entries).with("/two/dir").returns %w{b}

            %w{/one/dir/a /two/dir/b}.each { |f| File.expects(:directory?).with(f).returns true }

            Dir.expects(:entries).with("/one/dir/a").returns %w{c.rb}
            Dir.expects(:entries).with("/two/dir/b").returns %w{d.rb}

            %w{/one/dir/a/c.rb /two/dir/b/d.rb}.each { |f| Kernel.expects(:load).with(f) }

            @loader.load_all
        end

        it "should not load files in the util subdirectory" do
            @loader.expects(:search_path).returns %w{/one/dir}

            Dir.expects(:entries).with("/one/dir").returns %w{util}

            File.expects(:directory?).with("/one/dir/util").returns true

            Dir.expects(:entries).with("/one/dir/util").never

            @loader.load_all
        end

        it "should load all facts from the environment" do
            Facter.expects(:add).with('one')
            Facter.expects(:add).with('two')

            with_env "facter_one" => "yayness", "facter_two" => "boo" do
                @loader.load_all
            end
        end
    end
end
