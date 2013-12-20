#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/loader'

describe Facter::Util::Loader do
  before :each do
    Facter::Util::Loader.any_instance.unstub(:load_all)
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
    before :each do
      @loader = Facter::Util::Loader.new
      @settings = mock 'settings'
      @settings.stubs(:value).returns "/eh"
    end

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
      it "should be false for relative path to non-directory #{dir}" do
        File.stubs(:directory?).with(dir).returns false

        @loader.should_not be_valid_search_path dir
      end

      it "should be false for relative path to directory #{dir}" do
        File.stubs(:directory?).with(dir).returns true

        @loader.should_not be_valid_search_path dir
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
      it "should be false for absolute path to non-directory #{dir}" do
        File.stubs(:directory?).with(dir).returns false

        @loader.should_not be_valid_search_path dir
      end

      it "should be true for absolute path to directory #{dir}" do
        File.stubs(:directory?).with(dir).returns true

        @loader.should be_valid_search_path dir
      end
    end
  end

  describe "when determining the search path" do
    before do
      @loader = Facter::Util::Loader.new
      @settings = mock 'settings'
      @settings.stubs(:value).returns "/eh"
    end

    it "should include the facter subdirectory of all paths in ruby LOAD_PATH" do
      dirs = $LOAD_PATH.collect { |d| File.expand_path('facter', d) }
      @loader.stubs(:valid_search_path?).returns(true)
      File.stubs(:directory?).returns true

      paths = @loader.search_path

      dirs.each do |dir|
        paths.should be_include(dir)
      end
    end

    it "should exclude invalid search paths" do
      dirs = $LOAD_PATH.collect { |d| File.join(d, "facter") }
      @loader.stubs(:valid_search_path?).returns(false)
      paths = @loader.search_path
      dirs.each do |dir|
        paths.should_not be_include(dir)
      end
    end

    it "should include all search paths registered with Facter" do
      Facter.expects(:search_path).returns %w{/one /two}
      @loader.stubs(:valid_search_path?).returns true

      paths = @loader.search_path
      paths.should be_include("/one")
      paths.should be_include("/two")
    end

    it "should warn on invalid search paths registered with Facter" do
      Facter.expects(:search_path).returns %w{/one /two}
      @loader.stubs(:valid_search_path?).returns false
      @loader.stubs(:valid_search_path?).with('/one').returns true
      @loader.stubs(:valid_search_path?).with('/two').returns false
      Facter.expects(:warn).with('Excluding /two from search path. Fact file paths must be an absolute directory').once

      paths = @loader.search_path
      paths.should be_include("/one")
    end

    describe "and the FACTERLIB environment variable is set" do
      it "should include all paths in FACTERLIB" do
        Facter::Util::Resolution.with_env "FACTERLIB" => "/one/path#{File::PATH_SEPARATOR}/two/path" do
          @loader.stubs(:valid_search_path?).returns true
          paths = @loader.search_path
          %w{/one/path /two/path}.each do |dir|
            paths.should be_include(dir)
          end
        end
      end
    end
  end

  describe "when loading facts" do
    before do
      @loader = Facter::Util::Loader.new
      @loader.stubs(:search_path).returns []
    end

    it "should load values from the matching environment variable if one is present" do
      Facter.expects(:add).with(:testing)

      Facter::Util::Resolution.with_env "facter_testing" => "yayness" do
        @loader.load(:testing)
      end
    end

    it "should load any files in the search path with names matching the fact name" do
      @loader.expects(:search_path).returns %w{/one/dir /two/dir}
      File.stubs(:file?).returns false
      File.expects(:file?).with("/one/dir/testing.rb").returns true
      Kernel.expects(:load).with("/one/dir/testing.rb")

      @loader.load(:testing)
    end

    it 'should not load any ruby files from subdirectories matching the fact name in the search path' do
      @loader.stubs(:search_path).returns %w{/one/dir}
      File.stubs(:file?).returns false
      File.expects(:file?).with("/one/dir/testing.rb").returns true
      Kernel.expects(:load).with("/one/dir/testing.rb")

      File.stubs(:directory?).with("/one/dir/testing").returns true
      @loader.stubs(:search_path).returns %w{/one/dir}

      Dir.stubs(:entries).with("/one/dir/testing").returns %w{foo.rb bar.rb}
      %w{/one/dir/testing/foo.rb /one/dir/testing/bar.rb}.each do |f|
        File.stubs(:directory?).with(f).returns false
        Kernel.stubs(:load).with(f)
      end

      @loader.load(:testing)
    end

    it "should not load files that don't end in '.rb'" do
      @loader.expects(:search_path).returns %w{/one/dir}
      File.stubs(:file?).returns false
      File.expects(:file?).with("/one/dir/testing.rb").returns false
      File.expects(:exist?).with("/one/dir/testing").never
      Kernel.expects(:load).never

      @loader.load(:testing)
    end
  end

  describe "when loading all facts" do
    before :each do
      @loader = Facter::Util::Loader.new
      @loader.stubs(:search_path).returns []

      File.stubs(:directory?).returns true
    end

    it "should load all files in all search paths" do
      @loader.expects(:search_path).returns %w{/one/dir /two/dir}

      Dir.expects(:glob).with('/one/dir/*.rb').returns %w{/one/dir/a.rb /one/dir/b.rb}
      Dir.expects(:glob).with('/two/dir/*.rb').returns %w{/two/dir/c.rb /two/dir/d.rb}

      %w{/one/dir/a.rb /one/dir/b.rb /two/dir/c.rb /two/dir/d.rb}.each do |f|
        File.expects(:file?).with(f).returns true
        Kernel.expects(:load).with(f)
      end

      @loader.load_all
    end

    it "should not try to load subdirectories of search paths" do
      @loader.expects(:search_path).returns %w{/one/dir /two/dir}

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

      @loader.load_all
    end

    it "should not raise an exception when a file is unloadable" do
      @loader.expects(:search_path).returns %w{/one/dir}

      Dir.expects(:glob).with('/one/dir/*.rb').returns %w{/one/dir/a.rb}
      File.expects(:file?).with('/one/dir/a.rb').returns true

      Kernel.expects(:load).with("/one/dir/a.rb").raises(LoadError)
      Facter.expects(:warn)

      expect { @loader.load_all }.to_not raise_error
    end

    it "should load all facts from the environment" do
      Facter::Util::Resolution.with_env "facter_one" => "yayness", "facter_two" => "boo" do
        @loader.load_all
      end
      Facter.value(:one).should == 'yayness'
      Facter.value(:two).should == 'boo'
    end

    it "should only load all facts one time" do
      @loader.expects(:load_env).once
      @loader.load_all
      @loader.load_all
    end
  end

  it "should load facts on the facter search path only once" do
    facterlibdir = File.expand_path(File.dirname(__FILE__) + '../../../fixtures/unit/util/loader')
    Facter::Util::Resolution.with_env 'FACTERLIB' => facterlibdir do
      Facter::Util::Loader.new.load_all
      Facter.value(:nosuchfact).should be_nil
    end
  end
end
