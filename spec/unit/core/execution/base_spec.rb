require 'spec_helper'
require 'facter/core/execution'

describe Facter::Core::Execution::Base do

  describe "#with_env" do
    it "should execute the caller's block with the specified env vars" do
      test_env = { "LANG" => "C", "FOO" => "BAR" }
      subject.with_env test_env do
        test_env.keys.each do |key|
          ENV[key].should == test_env[key]
        end
      end
    end

    it "should restore pre-existing environment variables to their previous values" do
      orig_env = {}
      new_env = {}
      # an arbitrary sentinel value to use to temporarily set the environment vars to
      sentinel_value = "Abracadabra"

      # grab some values from the existing ENV (arbitrarily choosing 3 here)
      ENV.keys.first(3).each do |key|
        # save the original values so that we can test against them later
        orig_env[key] = ENV[key]
        # create bogus temp values for the chosen keys
        new_env[key] = sentinel_value
      end

      # verify that, during the 'with_env', the new values are used
      subject.with_env new_env do
        orig_env.keys.each do |key|
          ENV[key].should == new_env[key]
        end
      end

      # verify that, after the 'with_env', the old values are restored
      orig_env.keys.each do |key|
        ENV[key].should == orig_env[key]
      end
    end

    it "should not be affected by a 'return' statement in the yield block" do
      @sentinel_var = :resolution_test_foo.to_s

      # the intent of this test case is to test a yield block that contains a return statement.  However, it's illegal
      # to use a return statement outside of a method, so we need to create one here to give scope to the 'return'
      def handy_method()
        ENV[@sentinel_var] = "foo"
        new_env = { @sentinel_var => "bar" }

        subject.with_env new_env do
          ENV[@sentinel_var].should == "bar"
          return
        end
      end

      handy_method()

      ENV[@sentinel_var].should == "foo"

    end
  end

  describe "#exec" do

    it "switches LANG to C when executing the command" do
      subject.expects(:with_env).with('LANG' => 'C')
      subject.exec('foo')
    end

    it "switches LC_ALL to C when executing the command"

    it "expands the command before running it" do
      subject.stubs(:`).returns ''
      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      subject.exec('foo')
    end

    it "returns an empty string when the command could not be expanded" do
      subject.expects(:expand_command).with('foo').returns nil
      expect(subject.exec('foo')).to be_empty
    end

    it "logs a warning and returns an empty string when the command execution fails" do
      subject.expects(:`).with("/bin/foo").raises "kaboom!"
      Facter.expects(:warn).with("kaboom!")

      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.exec("foo")).to be_empty
    end

    it "launches a thread to wait on children if the command was interrupted" do
      subject.expects(:`).with("/bin/foo").raises "kaboom!"
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      Facter.stubs(:warn)
      Thread.expects(:new).yields
      Process.expects(:waitall).once

      subject.exec("foo")
    end

    it "returns the output of the command" do
      subject.expects(:`).with("/bin/foo").returns 'hi'
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.exec("foo")).to eq 'hi'
    end

    it "strips off trailing newlines" do
      subject.expects(:`).with("/bin/foo").returns "hi\n"
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.exec("foo")).to eq 'hi'
    end
  end
end
