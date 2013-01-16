require 'spec_helper'
require 'facter/application'

describe Facter::Application do
  describe '.parse' do
    it 'returns an empty hash when given no options' do
      Facter::Application.parse([]).should == {}
      Facter::Application.parse(['architecture', 'kernel']).should == {}
    end

    [:yaml, :json, :trace].each do |option_key|
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

    it 'mutates argv so that non-option arguments are left' do
      argv = ['-y', '--trace', 'uptime', 'virtual']
      Facter::Application.parse(argv)
      argv.should == ['uptime', 'virtual']
    end
  end
end
