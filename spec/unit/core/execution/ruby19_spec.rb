require 'spec_helper'

describe Facter::Core::Execution::Ruby19 do

  def stub_process
    Process.stubs(:spawn)
    Process.stubs(:waitpid)
  end

  def stub_io_pipe
    pipe_ends = [stub(:read => ''), stub(:close => nil, :fileno => 0)]
    IO.stubs(:pipe).returns(pipe_ends)
    pipe_ends
  end

  describe "#exec" do
    it "switches LANG to C when executing the command" do
      subject.expects(:with_env).with('LANG' => 'C')
      subject.exec('foo')
    end

    it "switches LC_ALL to C when executing the command"

    it "expands the command before running it" do
      stub_process()
      stub_io_pipe()

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      subject.exec('foo')
    end

    it "returns nil when the command could not be expanded" do
      stub_process()
      stub_io_pipe()

      subject.expects(:expand_command).with('foo').returns nil
      expect(subject.exec('foo')).to be_nil
    end

    it "logs a warning and returns nil when the command execution fails" do
      Process.stubs(:spawn).raises "kaboom!"
      Process.stubs(:waitpid)
      stub_io_pipe()

      Facter.expects(:warn).with "kaboom!"

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      expect(subject.exec('foo')).to be_nil
    end

    it "launches a thread to wait on children if the command was interrupted" do
      Process.stubs(:spawn).returns 1024
      Process.expects(:waitpid).with(1024)
      Thread.stubs(:new).yields
      stub_io_pipe()

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      expect(subject.exec('foo')).to be_nil
    end

    it "doesn't launch a thread if the command completed successfully" do
      Process.stubs(:spawn).returns 1024
      Process.expects(:waitpid).once.with(1024)
      Thread.expects(:new).never
      stub_io_pipe()

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      expect(subject.exec('foo')).to be_nil
    end

    it "returns the output of the command" do
      stub_process()
      stdout_r, _ = stub_io_pipe()

      stdout_r.unstub(:read)
      stdout_r.stubs(:read).returns "hello"

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      expect(subject.exec('foo')).to eq "hello"
    end

    it "strips off trailing newlines" do
      stub_process()
      stdout_r, _ = stub_io_pipe()

      stdout_r.unstub(:read)
      stdout_r.stubs(:read).returns "hello\n"

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      expect(subject.exec('foo')).to eq "hello"
    end

    it "normalizes the output of the command when the output is nil" do
      Process.stubs(:spawn).returns 1024
      Process.stubs(:waitpid)
      Thread.stubs(:new).yields
      stdout_r, _ = stub_io_pipe()

      stdout_r.unstub(:read)
      stdout_r.stubs(:read).returns "hello"

      subject.expects(:expand_command).with('foo').returns '/bin/foo'
      expect(subject.exec('foo')).to eq "hello"
    end
  end
end
