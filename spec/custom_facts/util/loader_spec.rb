#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::Loader do
  def loader_from(places)
    env = places[:env] || {}
    search_path = places[:search_path] || []
    loader = LegacyFacter::Util::Loader.new(env)
    allow(loader).to receive(:search_path).and_return(search_path)
    loader
  end

  it 'has a method for loading individual facts by name' do
    expect(LegacyFacter::Util::Loader.new).to respond_to(:load)
  end

  it 'has a method for loading all facts' do
    expect(LegacyFacter::Util::Loader.new).to respond_to(:load_all)
  end

  it 'has a method for returning directories containing facts' do
    expect(LegacyFacter::Util::Loader.new).to respond_to(:search_path)
  end

  describe '#valid_seach_path?' do
    let(:loader) { LegacyFacter::Util::Loader.new }

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
      ' \/'
    ].each do |dir|
      it "is false for relative path #{dir}" do
        expect(loader.send(:valid_search_path?, dir)).to be false
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
      '/ /..'
    ].each do |dir|
      it "is true for absolute path #{dir}" do
        expect(loader.send(:valid_search_path?, dir)).to be true
      end
    end
  end

  describe 'when determining the search path' do
    let(:loader) { LegacyFacter::Util::Loader.new }

    it 'includes the facter subdirectory of all paths in ruby LOAD_PATH' do
      dirs = $LOAD_PATH.collect { |d| File.expand_path('facter', d) }
      allow(loader).to receive(:valid_search_path?).and_return(true)
      allow(File).to receive(:directory?).and_return true

      paths = loader.search_path

      dirs.each do |dir|
        expect(paths).to include(dir)
      end
    end

    it 'excludes invalid search paths' do
      dirs = $LOAD_PATH.collect { |d| File.join(d, 'custom_facts') }
      allow(loader).to receive(:valid_search_path?).and_return(false)
      paths = loader.search_path
      dirs.each do |dir|
        expect(paths).not_to include(dir)
      end
    end

    it 'includes all search paths registered with Facter' do
      allow(LegacyFacter).to receive(:search_path).and_return %w[/one /two]
      allow(loader).to receive(:valid_search_path?).and_return true

      allow(File).to receive(:directory?).and_return false
      allow(File).to receive(:directory?).with('/one').and_return true
      allow(File).to receive(:directory?).with('/two').and_return true

      paths = loader.search_path
      expect(paths).to include('/one')
      expect(paths).to include('/two')
    end

    it 'warns on invalid search paths registered with Facter' do
      expect(LegacyFacter).to receive(:search_path).and_return %w[/one two/three]
      allow(loader).to receive(:valid_search_path?).and_return false
      allow(loader).to receive(:valid_search_path?).with('/one').and_return true
      allow(loader).to receive(:valid_search_path?).with('two/three').and_return false
      expect(LegacyFacter)
        .to receive(:warn)
        .with('Excluding two/three from search path. Fact file paths must be an absolute directory').once

      allow(File).to receive(:directory?).and_return false
      allow(File).to receive(:directory?).with('/one').and_return true

      paths = loader.search_path
      expect(paths).to include('/one')
      expect(paths).not_to include('two/three')
    end

    it 'strips paths that are valid paths but not are not present' do
      expect(LegacyFacter).to receive(:search_path).and_return %w[/one /two]
      allow(loader).to receive(:valid_search_path?).and_return false
      allow(loader).to receive(:valid_search_path?).with('/one').and_return true
      allow(loader).to receive(:valid_search_path?).with('/two').and_return true

      allow(File).to receive(:directory?).and_return false
      allow(File).to receive(:directory?).with('/one').and_return true
      allow(File).to receive(:directory?).with('/two').and_return false

      paths = loader.search_path
      expect(paths).to include('/one')
      expect(paths).not_to include('/two')
    end

    describe 'and the FACTERLIB environment variable is set' do
      it 'includes all paths in FACTERLIB' do
        loader = LegacyFacter::Util::Loader.new('FACTERLIB' => "/one/path#{File::PATH_SEPARATOR}/two/path")

        allow(File).to receive(:directory?).and_return false
        allow(File).to receive(:directory?).with('/one/path').and_return true
        allow(File).to receive(:directory?).with('/two/path').and_return true

        allow(loader).to receive(:valid_search_path?).and_return true
        paths = loader.search_path
        %w[/one/path /two/path].each do |dir|
          expect(paths).to include(dir)
        end
      end
    end
  end

  describe 'when loading facts' do
    it 'loads values from the matching environment variable if one is present' do
      loader = loader_from(env: { 'facter_testing' => 'yayness' })

      expect(LegacyFacter).to receive(:add).with('testing')

      loader.load(:testing)
    end

    it 'loads any files in the search path with names matching the fact name' do
      loader = loader_from(search_path: %w[/one/dir /two/dir])

      expect(loader).to receive(:search_path).and_return %w[/one/dir /two/dir]
      allow(FileTest).to receive(:file?).and_return false
      allow(FileTest).to receive(:file?).with('/one/dir/testing.rb').and_return true

      expect(Kernel).to receive(:load).with('/one/dir/testing.rb')

      loader.load(:testing)
    end

    it 'does not load any ruby files from subdirectories matching the fact name in the search path' do
      loader = LegacyFacter::Util::Loader.new
      allow(FileTest).to receive(:file?).and_return false
      expect(FileTest).to receive(:file?).with('/one/dir/testing.rb').and_return true
      expect(Kernel).to receive(:load).with('/one/dir/testing.rb')

      allow(File).to receive(:directory?).with('/one/dir/testing').and_return true
      allow(loader).to receive(:search_path).and_return %w[/one/dir]

      allow(Dir).to receive(:entries).with('/one/dir/testing').and_return %w[foo.rb bar.rb]
      %w[/one/dir/testing/foo.rb /one/dir/testing/bar.rb].each do |f|
        allow(File).to receive(:directory?).with(f).and_return false
        allow(Kernel).to receive(:load).with(f)
      end

      loader.load(:testing)
    end

    it "does not load files that don't end in '.rb'" do
      loader = LegacyFacter::Util::Loader.new
      expect(loader).to receive(:search_path).and_return %w[/one/dir]
      allow(FileTest).to receive(:file?).and_return false
      expect(FileTest).to receive(:file?).with('/one/dir/testing.rb').and_return false
      expect(File).not_to receive(:readable?).with('/one/dir/testing')
      expect(Kernel).not_to receive(:load)

      loader.load(:testing)
    end
  end

  describe 'when loading all facts' do
    let(:loader) { LegacyFacter::Util::Loader.new }

    before do
      allow(loader).to receive(:search_path).and_return([])

      allow(File).to receive(:directory?).and_return true
    end

    it 'loads all files in all search paths' do
      loader = loader_from(search_path: %w[/one/dir /two/dir])

      allow(Dir).to receive(:glob).with('/one/dir/*.rb').and_return %w[/one/dir/a.rb /one/dir/b.rb]
      allow(Dir).to receive(:glob).with('/two/dir/*.rb').and_return %w[/two/dir/c.rb /two/dir/d.rb]

      %w[/one/dir/a.rb /one/dir/b.rb /two/dir/c.rb /two/dir/d.rb].each do |f|
        expect(FileTest).to receive(:file?).with(f).and_return true
        expect(Kernel).to receive(:load).with(f)
      end

      loader.load_all
    end

    it 'does not try to load subdirectories of search paths' do
      expect(loader).to receive(:search_path).and_return %w[/one/dir /two/dir]

      # a.rb is a directory
      expect(Dir).to receive(:glob).with('/one/dir/*.rb').and_return %w[/one/dir/a.rb /one/dir/b.rb]
      expect(FileTest).to receive(:file?).with('/one/dir/a.rb').and_return false
      expect(FileTest).to receive(:file?).with('/one/dir/b.rb').and_return true
      expect(Kernel).to receive(:load).with('/one/dir/b.rb')

      # c.rb is a directory
      expect(Dir).to receive(:glob).with('/two/dir/*.rb').and_return %w[/two/dir/c.rb /two/dir/d.rb]
      expect(FileTest).to receive(:file?).with('/two/dir/c.rb').and_return false
      expect(FileTest).to receive(:file?).with('/two/dir/d.rb').and_return true
      expect(Kernel).to receive(:load).with('/two/dir/d.rb')

      loader.load_all
    end

    it 'does not raise an exception when a file is unloadable' do
      expect(loader).to receive(:search_path).and_return %w[/one/dir]

      expect(Dir).to receive(:glob).with('/one/dir/*.rb').and_return %w[/one/dir/a.rb]
      expect(FileTest).to receive(:file?).with('/one/dir/a.rb').and_return true

      expect(Kernel).to receive(:load).with('/one/dir/a.rb').and_raise(LoadError)
      expect(LegacyFacter).to receive(:warn)

      expect { loader.load_all }.not_to raise_error
    end

    it 'loads all facts from the environment' do
      Facter::Util::Resolution.with_env 'facter_one' => 'yayness', 'facter_two' => 'boo' do
        loader.load_all
      end
      expect(LegacyFacter.value(:one)).to eq 'yayness'
      expect(LegacyFacter.value(:two)).to eq 'boo'
    end

    it 'onlies load all facts one time' do
      loader = loader_from(env: {})
      expect(loader).to receive(:load_env).once

      loader.load_all
      loader.load_all
    end
  end

  it 'loads facts on the facter search path only once' do
    loader = loader_from(env: {})
    loader.load_all

    expect(loader).not_to receive(:kernel_load).with(/ec2/)
    loader.load(:ec2)
  end
end
