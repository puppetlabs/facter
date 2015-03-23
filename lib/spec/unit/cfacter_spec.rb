require 'spec_helper'

Facter.on_message do |level, message|
    puts message if level == :fatal
end

describe Facter do

  it 'should provide a version' do
    Facter.version.should_not be_nil
  end

  describe 'without resetting' do

    before :all do
      Facter.reset
    end

    it 'should not be an empty hash' do
      Facter.to_hash.should_not be_empty
    end

    it 'should return a fact for []' do
      fact = Facter[:facterversion]
      fact.should_not be_nil
      fact.name.should eq 'facterversion'
      fact.value.should eq Facter.version
    end

    it 'should return nil value for [] with unknown fact' do
      Facter[:not_a_fact].should be_nil
    end

    it 'should return nil for value with unknown fact' do
      Facter.value(:not_a_fact).should be_nil
    end

    it 'should contain a matching facter version' do
      version = Facter.value('facterversion')
      version.should eq Facter.version
      version.should eq Facter::FACTERVERSION
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
      facts['yaml_fact1'].should be_a String
      facts['yaml_fact2'].should be_a Integer
      facts['yaml_fact3'].should satisfy { |v| v == true || v == false }
      facts['yaml_fact4'].should be_a Float
      facts['yaml_fact5'].should be_a Array
      facts['yaml_fact6'].should be_a Hash
      facts['json_fact1'].should be_a String
      facts['json_fact2'].should be_a Integer
      facts['json_fact3'].should satisfy { |v| v == true || v == false }
      facts['json_fact4'].should be_a Float
      facts['json_fact5'].should be_a Array
      facts['json_fact6'].should be_a Hash
      facts['exe_fact1'].should be_a String
      facts['exe_fact2'].should be_a String
      facts['exe_fact3'].should be_nil
      facts['txt_fact1'].should be_a String
      facts['txt_fact2'].should be_a String
      facts['txt_fact3'].should be_nil
    end

    it 'should set search paths' do
      Facter.search('foo', 'bar', 'baz')
      Facter.search_path.should eq ['foo', 'bar', 'baz']
      Facter.reset
      Facter.search_path.should eq []
    end

    it 'should set external search paths' do
      Facter.search_external(['foo', 'bar', 'baz'])
      Facter.search_external_path.should eq ['foo', 'bar', 'baz']
    end
  end

end
