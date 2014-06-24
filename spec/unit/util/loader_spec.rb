#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/loader'

describe Facter::Util::Loader do
  before :each do
    Facter::Util::Loader.any_instance.unstub(:load_all)
  end

  def loader_from(places)
    env = places[:env] || {}
    search_path = places[:search_path] || []
    loader = Facter::Util::Loader.new(env)
    loader.stubs(:search_path).returns search_path
    loader
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

  describe "#valid_seach_path?" do
    let(:loader) { Facter::Util::Loader.new }

    # Used to have test for " " as a directory since that should
    # be a relative directory, but on Windows in both 1.8.7 and
    # 1.9.3 it is an absolute directory (WTF Windows). Considering
    # we didn't have a valid use case for a " " directory, the
    # test was removed.

    [
      '.',
      '..',
      '...',
      '.foo',
      '../foo',
      'foo',
      'foo/bar',
      'foo/../bar',
      ' /',
      ' \/',
    ].each do |dir|
      it "should be false for relative path #{dir}" do
        loader.should_not be_valid_search_path dir
      end
    end
    [
      '/.',
      '/..',
      '/...',
      '/.foo',
      '/../foo',
      '/foo',
      '/foo/bar',
      '/foo/../bar',
      '/ ',
      '/ /..',
    ].each do |dir|
      it "should be true for absolute path #{dir}" do
        loader.should be_valid_search_path dir
      end
    end
  end

  describe "when determining the search path" do
    let(:loader) { Facter::Util::Loader.new }

    it "should include the facter subdirectory of all paths in ruby LOAD_PATH" do
      dirs = $LOAD_PATH.collect { |d| File.expand_path('facter', d) }
      loader.stubs(:valid_search_path?).returns(true)
      File.stubs(:directory?).returns true

      paths = loader.search_path

      dirs.each do |dir|
        paths.should be_include(dir)
      end
    end

    it "should exclude invalid search paths" do
      dirs = $LOAD_PATH.collect { |d| File.join(d, "facter") }
      loader.stubs(:valid_search_path?).returns(false)
      paths = loader.search_path
      dirs.each do |dir|
        paths.should_not be_include(dir)
      end
    end

    it "should include all search paths registered with Facter" do
      Facter.expects(:search_path).returns %w{/one /two}
      loader.stubs(:valid_search_path?).returns true

      File.stubs(:directory?).returns false
      File.stubs(:directory?).with('/one').returns true
      File.stubs(:directory?).with('/two').returns true

      paths = loader.search_path
      paths.should be_include("/one")
      paths.should be_include("/two")
    end

    it "should warn on invalid search paths registered with Facter" do
      Facter.expects(:search_path).returns %w{/one two/three}
      loader.stubs(:valid_search_path?).returns false
      loader.stubs(:valid_search_path?).with('/one').returns true
      loader.stubs(:valid_search_path?).with('two/three').returns false
      Facter.expects(:warn).with('Excluding two/three from search path. Fact file paths must be an absolute directory').once

      File.stubs(:directory?).returns false
      File.stubs(:directory?).with('/one').returns true

      paths = loader.search_path
      paths.should be_include("/one")
      paths.should_not be_include("two/three")
    end

    it "should strip paths that are valid paths but not are not present" do
      Facter.expects(:search_path).returns %w{/one /two}
      loader.stubs(:valid_search_path?).returns false
      loader.stubs(:valid_search_path?).with('/one').returns true
      loader.stubs(:valid_search_path?).with('/two').returns true

      File.stubs(:directory?).returns false
      File.stubs(:directory?).with('/one').returns true
      File.stubs(:directory?).with('/two').returns false

      paths = loader.search_path
      paths.should be_include("/one")
      paths.should_not be_include('/two')
    end

    describe "and the FACTERLIB environment variable is set" do
      it "should include all paths in FACTERLIB" do
        loader = Facter::Util::Loader.new("FACTERLIB" => "/one/path#{File::PATH_SEPARATOR}/two/path")

      File.stubs(:directory?).returns false
      File.stubs(:directory?).with('/one/path').returns true
      File.stubs(:directory?).with('/two/path').returns true

        loader.stubs(:valid_search_path?).returns true
        paths = loader.search_path
        %w{/one/path /two/path}.each do |dir|
          paths.should be_include(dir)
        end
      end
    end
  end

  describe "when loading facts" do
    it "should load values from the matching environment variable if one is present" do
      loader = loader_from(:env => { "facter_testing" => "yayness" })

      Facter.expects(:add).with("testing")

      loader.load(:testing)
    end

    it "should load any files in the search path with names matching the fact name" do
      loader = loader_from(:search_path => %w{/one/dir /two/dir})

      loader.expects(:search_path).returns %w{/one/dir /two/dir}
      File.stubs(:file?).returns false
      File.expects(:file?).with("/one/dir/testing.rb").returns true

      Kernel.expects(:load).with("/one/dir/testing.rb")

      loader.load(:testing)
    end

    it 'should not load any ruby files from subdirectories matching the fact name in the search path' do
      loader = Facter::Util::Loader.new
      File.stubs(:file?).returns false
      File.expects(:file?).with("/one/dir/testing.rb").returns true
      Kernel.expects(:load).with("/one/dir/testing.rb")

      File.stubs(:directory?).with("/one/dir/testing").returns true
      loader.stubs(:search_path).returns %w{/one/dir}

      Dir.stubs(:entries).with("/one/dir/testing").returns %w{foo.rb bar.rb}
      %w{/one/dir/testing/foo.rb /one/dir/testing/bar.rb}.each do |f|
        File.stubs(:directory?).with(f).returns false
        Kernel.stubs(:load).with(f)
      end

      loader.load(:testing)
    end

    it "should not load files that don't end in '.rb'" do
      loader = Facter::Util::Loader.new
      loader.expects(:search_path).returns %w{/one/dir}
      File.stubs(:file?).returns false
      File.expects(:file?).with("/one/dir/testing.rb").returns false
      File.expects(:exist?).with("/one/dir/testing").never
      Kernel.expects(:load).never

      loader.load(:testing)
    end
  end

  describe "when loading all facts" do
    let(:loader) { Facter::Util::Loader.new }

    before :each do
      loader.stubs(:search_path).returns []

      File.stubs(:directory?).returns true
    end

    it "should load all files in all search paths" do
      loader = loader_from(:search_path => %w{/one/dir /two/dir})

      Dir.expects(:glob).with('/one/dir/*.rb').returns %w{/one/dir/a.rb /one/dir/b.rb}
      Dir.expects(:glob).with('/two/dir/*.rb').returns %w{/two/dir/c.rb /two/dir/d.rb}

      %w{/one/dir/a.rb /one/dir/b.rb /two/dir/c.rb /two/dir/d.rb}.each do |f|
        File.expects(:file?).with(f).returns true
        Kernel.expects(:load).with(f)
      end

      loader.load_all
    end

    it "should not try to load subdirectories of search paths" do
      loader.expects(:search_path).returns %w{/one/dir /two/dir}

      # a.rb is a directory
      Dir.expects(:glob).with('/one/dir/*.rb').returns %w{/one/dir/a.rb /one/dir/b.rb}
      File.expects(:file?).with('/one/dir/a.rb').returns false
      File.expects(:file?).with('/one/dir/b.rb').returns true
      Kernel.expects(:load).with('/one/dir/b.rb')

      # c.rb is a directory
      Dir.expects(:glob).with('/two/dir/*.rb').returns %w{/two/dir/c.rb /two/dir/d.rb}
      File.expects(:file?).with('/two/dir/c.rb').returns false
      File.expects(:file?).with('/two/dir/d.rb').returns true
      Kernel.expects(:load).with('/two/dir/d.rb')

      loader.load_all
    end

    it "should not raise an exception when a file is unloadable" do
      loader.expects(:search_path).returns %w{/one/dir}

      Dir.expects(:glob).with('/one/dir/*.rb').returns %w{/one/dir/a.rb}
      File.expects(:file?).with('/one/dir/a.rb').returns true

      Kernel.expects(:load).with("/one/dir/a.rb").raises(LoadError)
      Facter.expects(:warn)

      expect { loader.load_all }.to_not raise_error
    end

    it "should load all facts from the environment" do
      Facter::Util::Resolution.with_env "facter_one" => "yayness", "facter_two" => "boo" do
        loader.load_all
      end
      Facter.value(:one).should == 'yayness'
      Facter.value(:two).should == 'boo'
    end

    it "should only load all facts one time" do
      loader = loader_from(:env => {})
      loader.expects(:load_env).once

      loader.load_all
      loader.load_all
    end
  end

  it "should load facts on the facter search path only once" do
    loader = loader_from(:env => {})
    loader.load_all

    loader.expects(:kernel_load).with(regexp_matches(/ec2/)).never
    loader.load(:ec2)
  end
end
