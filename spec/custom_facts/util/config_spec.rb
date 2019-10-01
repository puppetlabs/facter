#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::Config do
  include PuppetlabsSpec::Files

  describe "ENV['HOME'] is unset", unless: LegacyFacter::Util::Root.root? do
    around do |example|
      LegacyFacter::Core::Execution.with_env('HOME' => nil) do
        example.run
      end
    end

    it 'should not set @external_facts_dirs' do
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      expect(LegacyFacter::Util::Config.external_facts_dirs).to be_empty
    end
  end

  describe 'is_windows? function' do
    it "should detect windows if Ruby RbConfig::CONFIG['host_os'] returns a windows OS" do
      host_os = %w[mswin win32 dos mingw cygwin]
      host_os.each do |h|
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return(h)
        expect(LegacyFacter::Util::Config.windows?).to be_truthy
      end
    end

    it "should not detect windows if Ruby RbConfig::CONFIG['host_os'] returns a non-windows OS" do
      host_os = %w[darwin linux]
      host_os.each do |h|
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return(h)
        expect(LegacyFacter::Util::Config.windows?).to be_falsey
      end
    end
  end

  describe 'is_mac? function' do
    it "should detect mac if Ruby RbConfig::CONFIG['host_os'] returns darwin" do
      host_os = ['darwin']
      host_os.each do |h|
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return(h)
        expect(LegacyFacter::Util::Config.mac?).to be_truthy
      end
    end
  end

  describe 'external_facts_dirs' do
    before :each do
      allow(LegacyFacter::Util::Root).to receive(:root?).and_return(true)
    end

    it 'should return the default value for linux' do
      allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(false)
      allow(LegacyFacter::Util::Config).to receive(:windows_data_dir).and_return(nil)
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      expect(LegacyFacter::Util::Config.external_facts_dirs)
        .to eq ['/opt/puppetlabs/custom_facts/facts.d',
                '/etc/custom_facts/facts.d',
                '/etc/puppetlabs/custom_facts/facts.d']
    end

    it 'should return the default value for windows 2008' do
      allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(true)
      allow(LegacyFacter::Util::Config).to receive(:windows_data_dir).and_return('C:\\ProgramData')
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      expect(LegacyFacter::Util::Config.external_facts_dirs)
        .to eq [File.join('C:\\ProgramData', 'PuppetLabs', 'custom_facts', 'facts.d')]
    end

    it 'should return the default value for windows 2003R2' do
      allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(true)
      allow(LegacyFacter::Util::Config).to receive(:windows_data_dir).and_return('C:\\Documents')
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      expect(LegacyFacter::Util::Config.external_facts_dirs)
        .to eq [File.join('C:\\Documents', 'PuppetLabs', 'custom_facts', 'facts.d')]
    end

    it "returns the old and new (AIO) paths under user's home directory when not root" do
      allow(LegacyFacter::Util::Root).to receive(:root?).and_return(false)
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      expect(LegacyFacter::Util::Config.external_facts_dirs)
        .to eq [File.expand_path(File.join('~', '.puppetlabs', 'opt', 'custom_facts', 'facts.d')),
                File.expand_path(File.join('~', '.custom_facts', 'facts.d'))]
    end

    it 'includes additional values when user appends to the list' do
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      original_values = LegacyFacter::Util::Config.external_facts_dirs.dup
      new_value = '/usr/share/newdir'
      LegacyFacter::Util::Config.external_facts_dirs << new_value
      expect(LegacyFacter::Util::Config.external_facts_dirs).to eq original_values + [new_value]
    end

    it 'should only output new values when explicitly set' do
      LegacyFacter::Util::Config.setup_default_ext_facts_dirs
      new_value = ['/usr/share/newdir']
      LegacyFacter::Util::Config.external_facts_dirs = new_value
      expect(LegacyFacter::Util::Config.external_facts_dirs).to eq new_value
    end
  end

  describe 'override_binary_dir' do
    it 'should return the default value for linux' do
      allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(false)
      LegacyFacter::Util::Config.setup_default_override_binary_dir
      expect(LegacyFacter::Util::Config.override_binary_dir).to eq '/opt/puppetlabs/puppet/bin'
    end

    it 'should return nil for windows' do
      allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(true)
      LegacyFacter::Util::Config.setup_default_override_binary_dir
      expect(LegacyFacter::Util::Config.override_binary_dir).to eq nil
    end

    it 'should output new values when explicitly set' do
      LegacyFacter::Util::Config.setup_default_override_binary_dir
      new_value = '/usr/share/newdir'
      LegacyFacter::Util::Config.override_binary_dir = new_value
      expect(LegacyFacter::Util::Config.override_binary_dir).to eq new_value
    end
  end
end
