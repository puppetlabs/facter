require 'spec_helper'
require 'facter/application'

describe Facter::Application do
  describe '.parse' do
    it 'returns an empty hash when given no options' do
      Facter::Application.parse([]).should == {}
      Facter::Application.parse(['architecture', 'kernel']).should == {}
    end

    [:yaml, :json].each do |option_key|
      it "sets options[:#{option_key}] when given --#{option_key}" do
        options = Facter::Application.parse(["--#{option_key}"])
        options[option_key].should be_true
      end
    end

    [['-y', :yaml], ['-j', :json]].each do |option, key|
      it "sets options[:#{key}] when given #{option}" do
        options = Facter::Application.parse([option])
        options[key].should be_true
      end
    end

    ['-d', '--debug'].each do |option|
      it "enables debugging when given #{option}" do
        Facter.debugging(false)
        Facter::Application.parse([option])
        Facter.should be_debugging
        Facter.debugging(false)
      end
    end

    it "enables tracing when given --trace" do
      Facter.trace(false)
      Facter::Application.parse(['--trace'])
      Facter.should be_trace
      Facter.trace(false)
    end

    ['-t', '--timing'].each do |option|
      it "enables timing when given #{option}" do
        Facter.timing(false)
        Facter::Application.parse([option])
        Facter.should be_timing
        Facter.timing(false)
      end
    end

    ['-p', '--puppet'].each do |option|
      it "calls load_puppet when given #{option}" do
        Facter::Application.expects(:load_puppet)
        Facter::Application.parse([option])
      end
    end

    ['-h', '--help'].each do |option|
      it "issues a deprecation message for `--puppet`" do
        Facter::Application.stubs(:exit).with(0)
        expect do
          Facter::Application.parse([option])
        end.to have_printed('Deprecated: use `puppet facts` instead')
      end
    end

    it 'mutates argv so that non-option arguments are left' do
      argv = ['-y', '--trace', 'uptime', 'virtual']
      Facter::Application.parse(argv)
      argv.should == ['uptime', 'virtual']
    end

    after(:all) do
      Facter.debugging(false)
      Facter.timing(false)
      Facter.trace(false)
    end
  end

  describe "formatting facts" do
    before do
      Facter.stubs(:to_hash)
      Facter.stubs(:value)
      Facter::Application.stubs(:puts)
    end

    it "delegates YAML formatting" do
      Facter::Util::Formatter.expects(:format_yaml)
      Facter::Application.stubs(:exit).with(0)
      Facter::Application.run(['--yaml'])
    end

    it "delegates JSON formatting", :if => Facter.json? do
      Facter::Util::Formatter.expects(:format_json)
      Facter::Application.stubs(:exit).with(0)
      Facter::Application.run(['--json'])
    end

    it "delegates plaintext formatting" do
      Facter::Util::Formatter.expects(:format_plaintext)
      Facter::Application.stubs(:exit).with(0)
      Facter::Application.run(['--plaintext'])
    end

    it "defaults to plaintext" do
      Facter::Util::Formatter.expects(:format_plaintext)
      Facter::Application.stubs(:exit).with(0)
      Facter::Application.run([])
    end
  end
end
