# encoding: UTF-8
require 'spec_helper'

Facter.on_message do |level, message|
    puts message if level == :fatal
end

describe Facter do

  it 'should provide a version' do
    expect(Facter.version).to_not be_nil
  end

  describe 'without resetting' do

    before :all do
      Facter.reset
    end

    it 'should not be an empty hash' do
      expect(Facter.to_hash).to_not be_empty
    end

    it 'should return a fact for []' do
      fact = Facter[:facterversion]
      expect(fact).to_not be_nil
      expect(fact.name).to eq('facterversion')
      expect(fact.value).to eq(Facter.version)
    end

    it 'should return nil value for [] with unknown fact' do
      expect(Facter[:not_a_fact]).to be_nil
    end

    it 'should return nil for value with unknown fact' do
      expect(Facter.value(:not_a_fact)).to be_nil
    end

    it 'should contain a matching facter version' do
      version = Facter.value('facterversion')
      expect(version).to eq(Facter.version)
      expect(version).to eq(Facter::FACTERVERSION)
    end
  end

  describe 'with resetting' do
    before :each do
      Facter.reset
    end

    it 'should load external facts' do
      # Check for windows vs posix for executable external facts
      windows = Facter.value('osfamily') == 'windows'
      Facter.reset

      Facter.search_external([
        File.expand_path('../../../lib/tests/fixtures/facts/external/yaml', File.dirname(__FILE__)),
        File.expand_path('../../../lib/tests/fixtures/facts/external/json', File.dirname(__FILE__)),
        File.expand_path('../../../lib/tests/fixtures/facts/external/text', File.dirname(__FILE__)),
        File.expand_path("../../../lib/tests/fixtures/facts/external/#{ if windows then 'windows' else 'posix' end }/execution", File.dirname(__FILE__))
      ])

      facts = Facter.to_hash
      expect(facts['yaml_fact1']).to be_a(String)
      expect(facts['yaml_fact2']).to be_a(Integer)
      expect(facts['yaml_fact3']).to(satisfy { |v| v == true || v == false })
      expect(facts['yaml_fact4']).to be_a(Float)
      expect(facts['yaml_fact5']).to be_a(Array)
      expect(facts['yaml_fact6']).to be_a(Hash)
      expect(facts['yaml_fact7']).to be_a(String)
      expect(facts['not_bool']).to be_a(String)
      expect(facts['not_int']).to be_a(String)
      expect(facts['not_double']).to be_a(String)
      expect(facts['json_fact1']).to be_a(String)
      expect(facts['json_fact2']).to be_a(Integer)
      expect(facts['json_fact3']).to(satisfy { |v| v == true || v == false })
      expect(facts['json_fact4']).to be_a(Float)
      expect(facts['json_fact5']).to be_a(Array)
      expect(facts['json_fact6']).to be_a(Hash)
      expect(facts['exe_fact1']).to be_a(String)
      expect(facts['exe_fact2']).to be_a(String)
      expect(facts['exe_fact3']).to be_nil
      expect(facts['txt_fact1']).to be_a(String)
      expect(facts['txt_fact2']).to be_a(String)
      expect(facts['txt_fact3']).to be_nil
    end

    it 'should set search paths' do
      Facter.search('foo', 'bar', 'baz')
      expect(Facter.search_path).to include('foo', 'bar', 'baz')
      Facter.reset
      expect(Facter.search_path).to eq([])
    end

    it 'should set external search paths' do
      Facter.search_external(['foo', 'bar', 'baz'])
      expect(Facter.search_external_path).to include('foo', 'bar', 'baz')
    end

    it 'should find encoded search paths' do
      snowman_path = File.expand_path('../../../lib/tests/fixtures/facts/external/zö', File.dirname(__FILE__))
      encoded_path = snowman_path.encode("Windows-1252")
      Facter.search(encoded_path)
      expect(Facter.search_path).to include(snowman_path)
      expect(Facter.value('snowman_fact')).to eq('olaf')
    end

    it 'should find encoded external search paths' do
      snowman_path = File.expand_path('../../../lib/tests/fixtures/facts/external/zö', File.dirname(__FILE__))
      encoded_path = snowman_path.encode("Windows-1252")
      Facter.search_external([encoded_path])
      expect(Facter.search_external_path).to include(snowman_path)
      expect(Facter.value('snowman_fact')).to eq('olaf')
    end

    it 'should support stubbing for confine testing' do
      Facter.fact(:osfamily).expects(:value).at_least(1).returns 'foo'
      expect(Facter.fact(:osfamily).value).to eq('foo')
      Facter.add(:test) do
        confine osfamily: 'foo'
        setcode do
          'bar'
        end
      end
      expect(Facter.value(:test)).to eq('bar')
    end

    it 'should allow stubbing on which and exec' do
      Facter::Util::Resolution.expects(:which).with("foo").returns('/usr/bin/foo')
      Facter::Util::Resolution.expects(:exec).with("foo").returns('bar')
      expect(Facter::Util::Resolution.which('foo')).to eq('/usr/bin/foo')
      expect(Facter::Util::Resolution.exec('foo')).to eq('bar')
    end
  end

end
