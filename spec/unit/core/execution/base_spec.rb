require 'spec_helper'
require 'facter/core/execution'

describe Facter::Core::Execution::Base do

  describe "#with_env" do
    it "should execute the caller's block with the specified env vars" do
      test_env = { 'LANG' => 'C', 'LC_ALL' => 'C', 'FOO' => 'BAR' }
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

  describe "#execute" do

    it "switches LANG and LC_ALL to C when executing the command" do
      subject.expects(:with_env).with('LC_ALL' => 'C', 'LANG' => 'C')
      subject.execute('foo')
    end

    it "expands the command before running it" do
      subject.stubs(:`).returns ''
      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      subject.execute('foo')
    end

    describe "and the command is not present" do
      it "raises an error when the :on_fail behavior is :raise" do
        subject.expects(:expand_command).with('foo').returns nil
        expect { subject.execute('foo') }.to raise_error(Facter::Core::Execution::ExecutionFailure)
      end

      it "returns the given value when :on_fail is set to a value" do
        subject.expects(:expand_command).with('foo').returns nil
        expect(subject.execute('foo', :on_fail => nil)).to be_nil
      end
    end

    describe "when command execution fails" do
      before do
        subject.expects(:`).with("/bin/foo").raises "kaboom!"
        subject.expects(:expand_command).with('foo').returns '/bin/foo'
      end

      it "raises an error when the :on_fail behavior is :raise" do
        expect { subject.execute('foo') }.to raise_error(Facter::Core::Execution::ExecutionFailure)
      end

      it "returns the given value when :on_fail is set to a value" do
        expect(subject.execute('foo', :on_fail => nil)).to be_nil
      end
    end

    it "launches a thread to wait on children if the command was interrupted" do
      subject.expects(:`).with("/bin/foo").raises "kaboom!"
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      Facter.stubs(:warn)
      Thread.expects(:new).yields
      Process.expects(:waitall).once

      subject.execute("foo", :on_fail => nil)
    end

    it "returns the output of the command" do
      subject.expects(:`).with("/bin/foo").returns 'hi'
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.execute("foo")).to eq 'hi'
    end

    it "strips off trailing newlines" do
      subject.expects(:`).with("/bin/foo").returns "hi\n"
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.execute("foo")).to eq 'hi'
    end
  end
end
