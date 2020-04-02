#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'
require 'tempfile'
require 'tmpdir'

describe LegacyFacter::Util::Parser do
  include PuppetlabsSpec::Files

  let(:data) { { 'one' => 'two', 'three' => 'four' } }

  describe '#extension_matches?' do
    it 'matches extensions when subclass uses match_extension' do
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.foobar', 'foobar')).to be true
    end

    it 'matches extensions when subclass uses match_extension with an array' do
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ext1', %w[ext1 ext2 ext3])).to be true
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ext2', %w[ext1 ext2 ext3])).to be true
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ext3', %w[ext1 ext2 ext3])).to be true
    end

    it 'matches extension ignoring case on file' do
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.EXT1', 'ext1')).to be true
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ExT1', 'ext1')).to be true
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.exT1', 'ext1')).to be true
    end

    it 'matches extension ignoring case for match_extension' do
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.EXT1', 'EXT1')).to be true
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ExT1', 'EXT1')).to be true
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.exT1', 'EXT1')).to be true
    end
  end

  describe '#parse_executable_output' do
    subject(:parser) { LegacyFacter::Util::Parser::Base.new('myfile.sh') }

    let(:yaml_data) { "one: two\nthree: four\n" }
    let(:keyvalue) { "one=two\nthree=four\n" }

    it 'receives yaml and returns hash' do
      expect(parser.parse_executable_output(yaml_data)).to eq data
    end

    it 'receives keyvalue and returns hash' do
      expect(parser.parse_executable_output(keyvalue)).to eq data
    end

    it 'raises no exception on nil' do
      expect(parser.parse_executable_output(nil)).to be_empty
    end

    it 'returns {} on invalid data' do
      expect(parser.parse_executable_output('random')).to be_empty
    end
  end

  describe 'yaml' do
    let(:data_in_yaml) { YAML.dump(data) }
    let(:data_file) { '/tmp/foo.yaml' }

    it 'returns a hash of whatever is stored on disk' do
      allow(File).to receive(:read).with(data_file).and_return(data_in_yaml)
      expect(LegacyFacter::Util::Parser.parser_for(data_file).results).to eq data
    end

    it 'handles exceptions and warn' do
      # YAML data with an error
      allow(File).to receive(:read).with(data_file).and_return(data_in_yaml + '}')
      allow(LegacyFacter).to receive(:warn).at_least(:one)
      expect { LegacyFacter::Util::Parser.parser_for(data_file).results }.not_to raise_error
    end
  end

  describe 'json' do
    let(:data_in_json) { JSON.dump(data) }
    let(:data_file) { '/tmp/foo.json' }

    it 'returns a hash of whatever is stored on disk' do
      pending('this test requires the json library') unless LegacyFacter.json?
      allow(File).to receive(:read).with(data_file).and_return(data_in_json)
      expect(LegacyFacter::Util::Parser.parser_for(data_file).results).to eq data
    end
  end

  describe 'txt' do
    let(:data_file) { '/tmp/foo.txt' }

    shared_examples_for 'txt parser' do
      it 'returns a hash of whatever is stored on disk' do
        allow(File).to receive(:read).with(data_file).and_return(data_in_txt)
        expect(LegacyFacter::Util::Parser.parser_for(data_file).results).to eq data
      end
    end

    context 'when is well formed data' do
      let(:data_in_txt) { "one=two\nthree=four\n" }

      it_behaves_like 'txt parser'
    end

    context 'when there is an extra equal sign' do
      let(:data_in_txt) { "one=two\nthree=four=five\n" }
      let(:data) { { 'one' => 'two', 'three' => 'four=five' } }

      it_behaves_like 'txt parser'
    end

    context 'when there is extra data' do
      let(:data_in_txt) { "one=two\nfive\nthree=four\n" }

      it_behaves_like 'txt parser'
    end
  end

  describe 'scripts' do
    let(:ext) { LegacyFacter::Util::Config.windows? ? '.bat' : '.sh' }
    let(:cmd) { "/tmp/foo#{ext}" }
    let(:data_in_txt) { "one=two\nthree=four\n" }
    let(:yaml_data) { "one: two\nthree: four\n" }

    def expects_script_to_return(path, content, result)
      allow(Facter::Core::Execution).to receive(:exec).with(path).and_return(content)
      allow(File).to receive(:executable?).with(path).and_return(true)
      allow(FileTest).to receive(:file?).with(path).and_return(true)

      expect(LegacyFacter::Util::Parser.parser_for(path).results).to eq result
    end

    def expects_parser_to_return_nil_for_directory(path)
      allow(FileTest).to receive(:file?).with(path).and_return(false)

      expect(LegacyFacter::Util::Parser.parser_for(path).results).to be nil
    end

    it 'returns a hash of whatever is returned by the executable' do
      expects_script_to_return(cmd, data_in_txt, data)
    end

    it 'does not parse a directory' do
      expects_parser_to_return_nil_for_directory(cmd)
    end

    it 'returns structured data' do
      expects_script_to_return(cmd, yaml_data, data)
    end

    it 'returns an empty hash when the script returns nil' do
      expects_script_to_return(cmd, nil, {})
    end

    it 'quotes scripts with spaces' do
      path = "/h a s s p a c e s#{ext}"

      expect(Facter::Core::Execution).to receive(:exec).with("\"#{path}\"").and_return(data_in_txt)

      expects_script_to_return(path, data_in_txt, data)
    end

    describe 'exe, bat, cmd, and com files' do
      let(:cmds) { ['/tmp/foo.bat', '/tmp/foo.cmd', '/tmp/foo.exe', '/tmp/foo.com'] }

      before do
        cmds.each do |cmd|
          allow(File).to receive(:executable?).with(cmd).and_return(true)
          allow(FileTest).to receive(:file?).with(cmd).and_return(true)
        end
      end

      it 'returns nothing parser if not on windows' do
        allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(false)
        cmds.each do |cmd|
          expect(LegacyFacter::Util::Parser.parser_for(cmd))
            .to be_an_instance_of(LegacyFacter::Util::Parser::NothingParser)
        end
      end

      it 'returns script parser if on windows' do
        allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(true)
        cmds.each do |cmd|
          expect(LegacyFacter::Util::Parser.parser_for(cmd))
            .to be_an_instance_of(LegacyFacter::Util::Parser::ScriptParser)
        end
      end
    end

    describe 'powershell' do
      let(:ps1) { '/tmp/foo.ps1' }

      def expects_to_parse_powershell(cmd, result)
        allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(true)
        allow(FileTest).to receive(:file?).with(ps1).and_return(true)

        expect(LegacyFacter::Util::Parser.parser_for(cmd).results).to eq result
      end

      it 'does not parse a directory' do
        expects_parser_to_return_nil_for_directory(ps1)
      end

      it 'parses output from powershell' do
        allow(Facter::Core::Execution).to receive(:exec).and_return(data_in_txt)
        expects_to_parse_powershell(ps1, data)
      end

      it 'parses yaml output from powershell' do
        allow(Facter::Core::Execution).to receive(:exec).and_return(yaml_data)
        expects_to_parse_powershell(ps1, data)
      end

      context 'when executing powershell', if: LegacyFacter::Util::Config.windows? do
        let(:sysnative_powershell) { "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe" }
        let(:system32_powershell)  { "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe" }

        let(:sysnative_regexp)  { /^\"#{Regexp.escape(sysnative_powershell)}\"/ }
        let(:system32_regexp)   { /^\"#{Regexp.escape(system32_powershell)}\"/ }
        let(:powershell_regexp) { /^\"#{Regexp.escape("powershell.exe")}\"/ }

        it 'prefers the sysnative alias to resolve 64-bit powershell on 32-bit ruby' do
          File.expects(:exists?).with(sysnative_powershell).returns(true)
          Facter::Core::Execution.expects(:exec).with(regexp_matches(sysnative_regexp)).returns(data_in_txt)

          expects_to_parse_powershell(ps1, data)
        end

        it "uses system32 if sysnative alias doesn't exist on 64-bit ruby" do
          File.expects(:exists?).with(sysnative_powershell).returns(false)
          File.expects(:exists?).with(system32_powershell).returns(true)
          Facter::Core::Execution.expects(:exec).with(regexp_matches(system32_regexp)).returns(data_in_txt)

          expects_to_parse_powershell(ps1, data)
        end

        it "uses 'powershell' as a last resort" do
          File.expects(:exists?).with(sysnative_powershell).returns(false)
          File.expects(:exists?).with(system32_powershell).returns(false)
          Facter::Core::Execution.expects(:exec).with(regexp_matches(powershell_regexp)).returns(data_in_txt)

          expects_to_parse_powershell(ps1, data)
        end
      end
    end
  end

  describe 'nothing parser' do
    it 'uses the nothing parser when there is no other parser' do
      expect(LegacyFacter::Util::Parser.parser_for('this.is.not.valid').results).to be nil
    end
  end
end
