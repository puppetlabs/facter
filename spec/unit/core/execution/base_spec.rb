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

  describe "#execute_with_env" do
    it "executes command with given environment" do
      Kernel.expects(:system).with({'FOO' => 'bar'}, '/bin/foo', anything, anything).returns true
      subject.execute_with_env({'FOO' => 'bar'}, '/bin/foo')
    end

    it "returns command output" do
      rout = mock('io_rout', :close => nil, :read => 'baz')
      rerr = mock('io_rerr', :close => nil, :read => '')
      wout = mock('io_wout', :close => nil)
      werr = mock('io_werr', :close => nil)
      IO.stubs(:pipe).returns [rout, wout], [rerr, werr]

      Kernel.expects(:system).returns true
      expect(subject.execute_with_env({}, '/bin/foo')).to eq('baz')
    end

    it "raises with stderr message on failure" do
      rout = mock('io_rout', :close => nil, :read => '')
      rerr = mock('io_rerr', :close => nil, :read => 'foo error')
      wout = mock('io_wout', :close => nil)
      werr = mock('io_werr', :close => nil)
      IO.stubs(:pipe).returns [rout, wout], [rerr, werr]

      Kernel.expects(:system).with({}, '/bin/foo', :err => werr, :out => wout).returns false
      expect{subject.execute_with_env({}, '/bin/foo')}.to raise_error StandardError, 'foo error'
    end

    it "raises with message on unknown failure" do
      Kernel.expects(:system).with({}, '/bin/foo', anything, anything).returns nil
      expect{subject.execute_with_env({}, '/bin/foo')}.to raise_error StandardError, 'failed to execute command'
    end
  end

  describe "#execute" do

    it "switches LANG to C when executing the command" do
      subject.expects(:execute_with_env).with(has_entry('LANG','C'), '/bin/foo').returns ''
      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      subject.execute('foo')
    end

    #e.g. LANG is not enough to get consistent output from /bin/date
    it "switches LC_ALL to C when executing the command" do
      subject.expects(:execute_with_env).with(has_entry('LC_ALL','C'), '/bin/foo').returns ''
      subject.expects(:expand_command).returns '/bin/foo'
      subject.execute('foo')
    end

    it "expands the command before running it" do
      subject.stubs(:execute_with_env).returns ''
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
        subject.expects(:execute_with_env).raises "kaboom!"
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
      subject.expects(:execute_with_env).raises "kaboom!"
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      Facter.stubs(:warn)
      Thread.expects(:new).yields
      Process.expects(:waitall).once

      subject.execute("foo", :on_fail => nil)
    end

    it "returns the output of the command" do
      subject.expects(:execute_with_env).returns 'hi'
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.execute("foo")).to eq 'hi'
    end

    it "strips off trailing newlines" do
      subject.expects(:execute_with_env).returns "hi\n"
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.execute("foo")).to eq 'hi'
    end
  end
end
