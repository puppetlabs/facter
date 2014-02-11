require 'spec_helper'

describe Facter::Core::Execution::Ruby18 do

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

    it "returns nil when the command could not be expanded" do
      subject.expects(:expand_command).with('foo').returns nil
      expect(subject.exec('foo')).to be_nil
    end

    it "logs a warning and returns nil when the command execution fails" do
      subject.expects(:`).with("/bin/foo").raises "kaboom!"
      Facter.expects(:warn).with("kaboom!")

      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.exec("foo")).to be_nil
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

    it "normalizes the output of the command when the output is nil" do
      subject.expects(:`).with("/bin/foo").returns ''
      subject.expects(:expand_command).with('foo').returns '/bin/foo'

      expect(subject.exec("foo")).to be_nil
    end
  end
end
