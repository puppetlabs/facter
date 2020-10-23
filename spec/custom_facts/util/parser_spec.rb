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
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ext3', %w[ext1 ext2 ext3])).to be true
    end

    it 'matches extension ignoring case on file' do
      expect(LegacyFacter::Util::Parser.extension_matches?('myfile.ExT1', 'ext1')).to be true
    end

    it 'matches extension ignoring case for match_extension' do
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

  shared_examples_for 'handling a not readable file' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read).with(data_file, nil).and_return(nil)
      allow(Facter).to receive(:log_exception).at_least(:once)
    end

    it 'handles not readable file' do
      expect { LegacyFacter::Util::Parser.parser_for(data_file).results }.not_to raise_error
    end
  end

  describe 'yaml' do
    let(:data_in_yaml) { YAML.dump(data) }
    let(:data_file) { '/tmp/foo.yaml' }

    it 'returns a hash of whatever is stored on disk' do
      allow(Facter::Util::FileHelper).to receive(:safe_read).with(data_file, nil).and_return(data_in_yaml)

      expect(LegacyFacter::Util::Parser.parser_for(data_file).results).to eq data
    end

    it 'handles exceptions' do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with(data_file, nil).and_return(data_in_yaml + '}')
      allow(Facter).to receive(:log_exception).at_least(:once)

      expect { LegacyFacter::Util::Parser.parser_for(data_file).results }.not_to raise_error
    end

    it_behaves_like 'handling a not readable file'
  end

  describe 'json' do
    let(:data_in_json) { JSON.dump(data) }
    let(:data_file) { '/tmp/foo.json' }

    it 'returns a hash of whatever is stored on disk' do
      pending('this test requires the json library') unless LegacyFacter.json?
      allow(Facter::Util::FileHelper).to receive(:safe_read).with(data_file, nil).and_return(data_in_json)

      expect(LegacyFacter::Util::Parser.parser_for(data_file).results).to eq data
    end

    it_behaves_like 'handling a not readable file'
  end

  describe 'txt' do
    let(:data_file) { '/tmp/foo.txt' }

    shared_examples_for 'txt parser' do
      it 'returns a hash of whatever is stored on disk' do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(data_file, nil).and_return(data_in_txt)

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

    it_behaves_like 'handling a not readable file'
  end

  describe 'scripts' do
    let(:ext) { LegacyFacter::Util::Config.windows? ? '.bat' : '.sh' }
    let(:cmd) { "/tmp/foo#{ext}" }
    let(:data_in_txt) { "one=two\nthree=four\n" }
    let(:yaml_data) { "one: two\nthree: four\n" }
    let(:logger) { instance_spy(Facter::Log) }

    def expects_script_to_return(path, content, result, err = nil)
      allow(Facter::Core::Execution).to receive(:execute_command).with(path, nil).and_return([content, err])
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

    it 'handles Symbol correctly' do
      yaml_data = "---\n:one: :two\nthree: four\n"
      exptected_data = { :one => :two, 'three' => 'four' }
      expects_script_to_return(cmd, yaml_data, exptected_data)
    end

    it 'writes warning message' do
      allow(Facter).to receive(:warn).at_least(:once)
      allow(Facter::Log).to receive(:new).with("foo#{ext}").and_return(logger)

      expects_script_to_return(cmd, yaml_data, data, 'some error')
      expect(logger).to have_received(:warn).with("Command /tmp/foo#{ext} completed with the "\
        'following stderr message: some error')
    end

    it 'handles Time correctly' do
      yaml_data = "---\nfirst: 2020-07-15 05:38:12.427678398 +00:00\n"
      allow(Facter::Core::Execution).to receive(:execute_command).with(cmd, nil).and_return([yaml_data, nil])
      allow(File).to receive(:executable?).with(cmd).and_return(true)
      allow(FileTest).to receive(:file?).with(cmd).and_return(true)

      expect(LegacyFacter::Util::Parser.parser_for(cmd).results['first']).to be_a(Time)
    end

    it 'returns an empty hash when the script returns nil' do
      expects_script_to_return(cmd, nil, {})
    end

    it 'quotes scripts with spaces' do
      path = "/h a s s p a c e s#{ext}"

      expect(Facter::Core::Execution).to receive(:execute_command)
        .with("\"#{path}\"", nil).and_return([data_in_txt, nil])
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
      let(:logger) { instance_spy(Facter::Log) }

      before do
        allow(File).to receive(:readable?).and_return(false)
      end

      def expects_to_parse_powershell(cmd, result)
        allow(LegacyFacter::Util::Config).to receive(:windows?).and_return(true)
        allow(FileTest).to receive(:file?).with(ps1).and_return(true)

        expect(LegacyFacter::Util::Parser.parser_for(cmd).results).to eq result
      end

      it 'does not parse a directory' do
        expects_parser_to_return_nil_for_directory(ps1)
      end

      it 'parses output from powershell' do
        allow(Facter::Core::Execution).to receive(:execute_command).and_return([data_in_txt, nil])

        expects_to_parse_powershell(ps1, data)
      end

      it 'parses yaml output from powershell' do
        allow(Facter::Core::Execution).to receive(:execute_command).and_return([yaml_data, nil])

        expects_to_parse_powershell(ps1, data)
      end

      it 'logs warning from powershell' do
        allow(Facter::Core::Execution).to receive(:execute_command).and_return([yaml_data, 'some error'])
        allow(Facter::Log).to receive(:new).with('foo.ps1').and_return(logger)

        expects_to_parse_powershell(ps1, data)
        expect(logger).to have_received(:warn).with('Command "powershell.exe" -NoProfile -NonInteractive -NoLogo '\
          '-ExecutionPolicy Bypass -File "/tmp/foo.ps1" completed with the following stderr message: some error')
      end

      context 'when executing powershell' do
        let(:sysnative_powershell) { "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe" }
        let(:system32_powershell)  { "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe" }

        let(:sysnative_regexp)  { /^\"#{Regexp.escape(sysnative_powershell)}\"/ }
        let(:system32_regexp)   { /^\"#{Regexp.escape(system32_powershell)}\"/ }
        let(:powershell_regexp) { /^\"#{Regexp.escape("powershell.exe")}\"/ }

        it 'prefers the sysnative alias to resolve 64-bit powershell on 32-bit ruby' do
          allow(File).to receive(:readable?).with(sysnative_powershell).and_return(true)
          allow(Facter::Core::Execution)
            .to receive(:execute_command)
            .with(sysnative_regexp)
            .and_return([data_in_txt, nil])

          expects_to_parse_powershell(ps1, data)
        end

        it "uses system32 if sysnative alias doesn't exist on 64-bit ruby" do
          allow(File).to receive(:readable?).with(sysnative_powershell).and_return(false)
          allow(File).to receive(:readable?).with(system32_powershell).and_return(true)
          allow(Facter::Core::Execution).to receive(:execute_command).with(system32_regexp)
                                                                     .and_return([data_in_txt, nil])

          expects_to_parse_powershell(ps1, data)
        end

        it "uses 'powershell' as a last resort" do
          allow(File).to receive(:readable?).with(sysnative_powershell).and_return(false)
          allow(File).to receive(:readable?).with(system32_powershell).and_return(false)
          allow(Facter::Core::Execution)
            .to receive(:execute_command)
            .with(powershell_regexp)
            .and_return([data_in_txt, nil])

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

  describe LegacyFacter::Util::Parser::YamlParser do
    let(:yaml_parser) { LegacyFacter::Util::Parser::YamlParser.new(nil, yaml_content) }

    describe '#parse_results' do
      context 'when yaml contains Time formatted fields' do
        context 'when time zone is present' do
          let(:yaml_content) { load_fixture('external_fact_yaml').read }

          it 'treats it as a string' do
            expected_result = { 'testsfact' => { 'time' => '2020-04-28 01:44:08.148119000 +01:01' } }

            expect(yaml_parser.parse_results).to eq(expected_result)
          end
        end

        context 'when time zone is missing' do
          let(:yaml_content) { load_fixture('external_fact_yaml_no_zone').read }

          it 'is interpreted as a string' do
            expected_result = { 'testsfact' => { 'time' => '2020-04-28 01:44:08.148119000' } }

            expect(yaml_parser.parse_results).to eq(expected_result)
          end
        end
      end

      context 'when yaml contains Date formatted fields' do
        let(:yaml_content) { load_fixture('external_fact_yaml_date').read }

        it 'loads date' do
          expected_result = { 'testsfact' => { 'date' => Date.parse('2020-04-28') } }

          expect(yaml_parser.parse_results).to eq(expected_result)
        end
      end
    end
  end
end
