#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/resolution'

describe Facter::Util::Resolution do
  it "should require a name" do
    lambda { Facter::Util::Resolution.new }.should raise_error(ArgumentError)
  end

  it "should have a name" do
    Facter::Util::Resolution.new("yay").name.should == "yay"
  end

  it "should have a method for setting the weight" do
    Facter::Util::Resolution.new("yay").should respond_to(:has_weight)
  end

  it "should have a method for setting the code" do
    Facter::Util::Resolution.new("yay").should respond_to(:setcode)
  end

  it "should support a timeout value" do
    Facter::Util::Resolution.new("yay").should respond_to(:timeout=)
  end

  it "should default to a timeout of 0 seconds" do
    Facter::Util::Resolution.new("yay").limit.should == 0
  end

  it "should default to nil for code" do
    Facter::Util::Resolution.new("yay").code.should be_nil
  end

  it "should default to nil for interpreter" do
    Facter.expects(:warnonce).with("The 'Facter::Util::Resolution.interpreter' method is deprecated and will be removed in a future version.")
    Facter::Util::Resolution.new("yay").interpreter.should be_nil
  end

  it "should provide a 'limit' method that returns the timeout" do
    res = Facter::Util::Resolution.new("yay")
    res.timeout = "testing"
    res.limit.should == "testing"
  end

  describe "when setting the code" do
    before do
      Facter.stubs(:warnonce)
      @resolve = Facter::Util::Resolution.new("yay")
    end

    it "should deprecate the interpreter argument to 'setcode'" do
      Facter.expects(:warnonce).with("The interpreter parameter to 'setcode' is deprecated and will be removed in a future version.")
      @resolve.setcode "foo", "bar"
      @resolve.interpreter.should == "bar"
    end

    it "should deprecate the interpreter= method" do
      Facter.expects(:warnonce).with("The 'Facter::Util::Resolution.interpreter=' method is deprecated and will be removed in a future version.")
      @resolve.interpreter = "baz"
      @resolve.interpreter.should == "baz"
    end

    it "should deprecate the interpreter method" do
      Facter.expects(:warnonce).with("The 'Facter::Util::Resolution.interpreter' method is deprecated and will be removed in a future version.")
      @resolve.interpreter
    end

    it "should set the code to any provided string" do
      @resolve.setcode "foo"
      @resolve.code.should == "foo"
    end

    it "should set the code to any provided block" do
      block = lambda { }
      @resolve.setcode(&block)
      @resolve.code.should equal(block)
    end

    it "should prefer the string over a block" do
      @resolve.setcode("foo") { }
      @resolve.code.should == "foo"
    end

    it "should fail if neither a string nor block has been provided" do
      lambda { @resolve.setcode }.should raise_error(ArgumentError)
    end
  end

  it "should be able to return a value" do
    Facter::Util::Resolution.new("yay").should respond_to(:value)
  end

  describe "when returning the value" do
    before do
      @resolve = Facter::Util::Resolution.new("yay")
    end

    describe "and setcode has not been called" do
      it "should return nil" do
        Facter::Util::Resolution.expects(:exec).with(nil, nil).never
        @resolve.value.should be_nil
      end
    end

    describe "and the code is a string" do
      describe "on windows" do
        before do
          Facter::Util::Config.stubs(:is_windows?).returns(true)
        end

        it "should return the result of executing the code" do
          @resolve.setcode "/bin/foo"
          Facter::Util::Resolution.expects(:exec).once.with("/bin/foo").returns "yup"

          @resolve.value.should == "yup"
        end

        it "should return nil if the value is an empty string" do
          @resolve.setcode "/bin/foo"
          Facter::Util::Resolution.expects(:exec).once.returns ""
          @resolve.value.should be_nil
        end
      end

      describe "on non-windows systems" do
        before do
          Facter::Util::Config.stubs(:is_windows?).returns(false)
        end

        it "should return the result of executing the code" do
          @resolve.setcode "/bin/foo"
          Facter::Util::Resolution.expects(:exec).once.with("/bin/foo").returns "yup"

          @resolve.value.should == "yup"
        end

        it "should return nil if the value is an empty string" do
          @resolve.setcode "/bin/foo"
          Facter::Util::Resolution.expects(:exec).once.returns ""
          @resolve.value.should be_nil
        end
      end
    end

    describe "and the code is a block" do
      it "should warn but not fail if the code fails" do
        @resolve.setcode { raise "feh" }
        Facter.expects(:warn)
        @resolve.value.should be_nil
      end

      it "should return the value returned by the block" do
        @resolve.setcode { "yayness" }
        @resolve.value.should == "yayness"
      end

      it "should return nil if the value is an empty string" do
        @resolve.setcode { "" }
        @resolve.value.should be_nil
      end

      it "should return nil if the value is an empty block" do
        @resolve.setcode { "" }
        @resolve.value.should be_nil
      end

      it "should use its limit method to determine the timeout, to avoid conflict when a 'timeout' method exists for some other reason" do
        @resolve.expects(:timeout).never
        @resolve.expects(:limit).returns "foo"
        Timeout.expects(:timeout).with("foo")

        @resolve.setcode { sleep 2; "raise This is a test"}
        @resolve.value
      end

      it "should timeout after the provided timeout" do
        @resolve.expects(:warn)
        @resolve.timeout = 0.1
        @resolve.setcode { sleep 2; raise "This is a test" }
        Thread.expects(:new).yields

        @resolve.value.should be_nil
      end

      it "should waitall to avoid zombies if the timeout is exceeded" do
        @resolve.stubs(:warn)
        @resolve.timeout = 0.1
        @resolve.setcode { sleep 2; raise "This is a test" }

        Thread.expects(:new).yields
        Process.expects(:waitall)

        @resolve.value
      end

      it 'include a stack trace when tracing is on' do
        Facter.tracing(1)
        @resolve.setcode { raise 'This is a test' }

        # This basically ensures the array returns isn't 1 (indicating no stack
        # trace) its not great, but I can't see a better way to do this in
        # mocha.
        Facter.expects(:warn).with(Not(responds_with(:length, 1)))

        @resolve.value
      end

      it 'do not include a stack trace when tracing is off' do
        Facter.tracing(0)
        @resolve.setcode { raise 'This is a test' }

        # This basically ensures the array length is only 1
        Facter.expects(:warn).with(responds_with(:length, 1))

        @resolve.value
      end
    end
  end

  it "should return its value when converted to a string" do
    @resolve = Facter::Util::Resolution.new("yay")
    @resolve.expects(:value).returns "myval"
    @resolve.to_s.should == "myval"
  end

  it "should allow the adding of confines" do
    Facter::Util::Resolution.new("yay").should respond_to(:confine)
  end

  it "should provide a method for returning the number of confines" do
    @resolve = Facter::Util::Resolution.new("yay")
    @resolve.confine "one" => "foo", "two" => "fee"
    @resolve.weight.should == 2
  end

  it "should return 0 confines when no confines have been added" do
    Facter::Util::Resolution.new("yay").weight.should == 0
  end

  it "should provide a way to set the weight" do
    @resolve = Facter::Util::Resolution.new("yay")
    @resolve.has_weight(45)
    @resolve.weight.should == 45
  end

  it "should allow the weight to override the number of confines" do
    @resolve = Facter::Util::Resolution.new("yay")
    @resolve.confine "one" => "foo", "two" => "fee"
    @resolve.weight.should == 2
    @resolve.has_weight(45)
    @resolve.weight.should == 45
  end

  it "should have a method for determining if it is suitable" do
    Facter::Util::Resolution.new("yay").should respond_to(:suitable?)
  end

  describe "when adding confines" do
    before do
      @resolve = Facter::Util::Resolution.new("yay")
    end

    it "should accept a hash of fact names and values" do
      lambda { @resolve.confine :one => "two" }.should_not raise_error
    end

    it "should create a Util::Confine instance for every argument in the provided hash" do
      Facter::Util::Confine.expects(:new).with("one", "foo")
      Facter::Util::Confine.expects(:new).with("two", "fee")

      @resolve.confine "one" => "foo", "two" => "fee"
    end

  end

  describe "when determining suitability" do
    before do
      @resolve = Facter::Util::Resolution.new("yay")
    end

    it "should always be suitable if no confines have been added" do
      @resolve.should be_suitable
    end

    it "should be unsuitable if any provided confines return false" do
      confine1 = mock 'confine1', :true? => true
      confine2 = mock 'confine2', :true? => false
      Facter::Util::Confine.expects(:new).times(2).returns(confine1).then.returns(confine2)
      @resolve.confine :one => :two, :three => :four

      @resolve.should_not be_suitable
    end

    it "should be suitable if all provided confines return true" do
      confine1 = mock 'confine1', :true? => true
      confine2 = mock 'confine2', :true? => true
      Facter::Util::Confine.expects(:new).times(2).returns(confine1).then.returns(confine2)
      @resolve.confine :one => :two, :three => :four

      @resolve.should be_suitable
    end
  end

  it "should have a class method for executing code" do
    Facter::Util::Resolution.should respond_to(:exec)
  end

  # taken from puppet: spec/unit/util_spec.rb
  describe "#absolute_path?" do
    context "when run on unix", :as_platform => :posix do
      %w[/ /foo /foo/../bar //foo //Server/Foo/Bar //?/C:/foo/bar /\Server/Foo /foo//bar/baz].each do |path|
        it "should return true for #{path}" do
          Facter::Util::Resolution.should be_absolute_path(path)
        end
      end

      %w[. ./foo \foo C:/foo \\Server\Foo\Bar \\?\C:\foo\bar \/?/foo\bar \/Server/foo foo//bar/baz].each do |path|
        it "should return false for #{path}" do
          Facter::Util::Resolution.should_not be_absolute_path(path)
        end
      end
    end

    context "when run on windows", :as_platform => :windows  do
      %w[C:/foo C:\foo \\\\Server\Foo\Bar \\\\?\C:\foo\bar //Server/Foo/Bar //?/C:/foo/bar /\?\C:/foo\bar \/Server\Foo/Bar c:/foo//bar//baz].each do |path|
        it "should return true for #{path}" do
          Facter::Util::Resolution.should be_absolute_path(path)
        end
      end

      %w[/ . ./foo \foo /foo /foo/../bar //foo C:foo/bar foo//bar/baz].each do |path|
        it "should return false for #{path}" do
          Facter::Util::Resolution.should_not be_absolute_path(path)
        end
      end
    end
  end

  describe "#search_paths" do
    context "on windows", :as_platform => :windows do
      it "should use the PATH environment variable to determine locations" do
        ENV.expects(:[]).with('PATH').returns 'C:\Windows;C:\Windows\System32'
        Facter::Util::Resolution.search_paths.should == %w{C:\Windows C:\Windows\System32}
      end
    end

    context "on posix", :as_platform => :posix do
      it "should use the PATH environment variable plus /sbin and /usr/sbin on unix" do
        ENV.expects(:[]).with('PATH').returns "/bin:/usr/bin"
        Facter::Util::Resolution.search_paths.should == %w{/bin /usr/bin /sbin /usr/sbin}
      end
    end
  end

  describe "#which" do
    context "when run on posix", :as_platform => :posix  do
      before :each do
        Facter::Util::Resolution.stubs(:search_paths).returns [ '/bin', '/sbin', '/usr/sbin']
      end

      context "and provided with an absolute path" do
        it "should return the binary if executable" do
          File.expects(:executable?).with('/opt/foo').returns true
          Facter::Util::Resolution.which('/opt/foo').should == '/opt/foo'
        end

        it "should return nil if the binary is not executable" do
          File.expects(:executable?).with('/opt/foo').returns false
          Facter::Util::Resolution.which('/opt/foo').should be_nil
        end
      end

      context "and not provided with an absolute path" do
        it "should return the absolute path if found" do
          File.expects(:executable?).with('/bin/foo').returns false
          File.expects(:executable?).with('/sbin/foo').returns true
          File.expects(:executable?).with('/usr/sbin/foo').never
          Facter::Util::Resolution.which('foo').should == '/sbin/foo'
        end

        it "should return nil if not found" do
          File.expects(:executable?).with('/bin/foo').returns false
          File.expects(:executable?).with('/sbin/foo').returns false
          File.expects(:executable?).with('/usr/sbin/foo').returns false
          Facter::Util::Resolution.which('foo').should be_nil
        end
      end
    end

    context "when run on windows", :as_platform => :windows do
      before :each do
        Facter::Util::Resolution.stubs(:search_paths).returns ['C:\Windows\system32', 'C:\Windows', 'C:\Windows\System32\Wbem' ]
        ENV.stubs(:[]).with('PATHEXT').returns nil
      end

      context "and provided with an absolute path" do
        it "should return the binary if executable" do
          File.expects(:executable?).with('C:\Tools\foo.exe').returns true
          File.expects(:executable?).with('\\\\remote\dir\foo.exe').returns true
          Facter::Util::Resolution.which('C:\Tools\foo.exe').should == 'C:\Tools\foo.exe'
          Facter::Util::Resolution.which('\\\\remote\dir\foo.exe').should == '\\\\remote\dir\foo.exe'
        end

        it "should return the binary with added extension if executable" do
          ['.COM', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with('C:\Windows\system32\netsh'+ext).returns false
          end
          File.expects(:executable?).with('C:\Windows\system32\netsh.EXE').returns true

          Facter.expects(:warnonce).with('Using Facter::Util::Resolution.which with an absolute path like C:\\Windows\\system32\\netsh but no fileextension is deprecated. Please add the correct extension (.EXE)')
          Facter::Util::Resolution.which('C:\Windows\system32\netsh').should == 'C:\Windows\system32\netsh.EXE'
        end

        it "should return nil if the binary is not executable" do
          File.expects(:executable?).with('C:\Tools\foo.exe').returns false
          File.expects(:executable?).with('\\\\remote\dir\foo.exe').returns false
          Facter::Util::Resolution.which('C:\Tools\foo.exe').should be_nil
          Facter::Util::Resolution.which('\\\\remote\dir\foo.exe').should be_nil
        end
      end

      context "and not provided with an absolute path" do
        it "should return the absolute path if found" do
          File.expects(:executable?).with('C:\Windows\system32\foo.exe').returns false
          File.expects(:executable?).with('C:\Windows\foo.exe').returns true
          File.expects(:executable?).with('C:\Windows\System32\Wbem\foo.exe').never
          Facter::Util::Resolution.which('foo.exe').should == 'C:\Windows\foo.exe'
        end

        it "should return the absolute path with file extension if found" do
          ['.COM', '.EXE', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with('C:\Windows\system32\foo'+ext).returns false
            File.stubs(:executable?).with('C:\Windows\System32\Wbem\foo'+ext).returns false
          end
          ['.COM', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with('C:\Windows\foo'+ext).returns false
          end
          File.stubs(:executable?).with('C:\Windows\foo.EXE').returns true

          Facter::Util::Resolution.which('foo').should == 'C:\Windows\foo.EXE'
        end

        it "should return nil if not found" do
          File.expects(:executable?).with('C:\Windows\system32\foo.exe').returns false
          File.expects(:executable?).with('C:\Windows\foo.exe').returns false
          File.expects(:executable?).with('C:\Windows\System32\Wbem\foo.exe').returns false
          Facter::Util::Resolution.which('foo.exe').should be_nil
        end
      end
    end

    describe "#expand_command" do
      context "on windows", :as_platform => :windows do
        it "should expand binary" do
          Facter::Util::Resolution.expects(:which).with('cmd').returns 'C:\Windows\System32\cmd'
          Facter::Util::Resolution.expand_command(
            'cmd /c echo foo > C:\bar'
          ).should == 'C:\Windows\System32\cmd /c echo foo > C:\bar'
        end

        it "should expand double quoted binary" do
          Facter::Util::Resolution.expects(:which).with('my foo').returns 'C:\My Tools\my foo.exe'
          Facter::Util::Resolution.expand_command('"my foo" /a /b').should == '"C:\My Tools\my foo.exe" /a /b'
        end

        it "should not expand single quoted binary" do
          Facter::Util::Resolution.expects(:which).with('\'C:\My').returns nil
          Facter::Util::Resolution.expand_command('\'C:\My Tools\foo.exe\' /a /b').should be_nil
        end

        it "should quote expanded binary if found in path with spaces" do
          Facter::Util::Resolution.expects(:which).with('foo').returns 'C:\My Tools\foo.exe'
          Facter::Util::Resolution.expand_command('foo /a /b').should == '"C:\My Tools\foo.exe" /a /b'
        end

        it "should return nil if not found" do
          Facter::Util::Resolution.expects(:which).with('foo').returns nil
          Facter::Util::Resolution.expand_command('foo /a | stuff >> /dev/null').should be_nil
        end
      end

      context "on unix", :as_platform => :posix do
        it "should expand binary" do
          Facter::Util::Resolution.expects(:which).with('foo').returns '/bin/foo'
          Facter::Util::Resolution.expand_command('foo -a | stuff >> /dev/null').should == '/bin/foo -a | stuff >> /dev/null'
        end

        it "should expand double quoted binary" do
          Facter::Util::Resolution.expects(:which).with('/tmp/my foo').returns '/tmp/my foo'
          Facter::Util::Resolution.expand_command(%q{"/tmp/my foo" bar}).should == %q{"/tmp/my foo" bar}
        end

        it "should expand single quoted binary" do
          Facter::Util::Resolution.expects(:which).with('my foo').returns '/home/bob/my path/my foo'
          Facter::Util::Resolution.expand_command(%q{'my foo' -a}).should == %q{'/home/bob/my path/my foo' -a}
        end

        it "should quote expanded binary if found in path with spaces" do
          Facter::Util::Resolution.expects(:which).with('foo.sh').returns '/home/bob/my tools/foo.sh'
          Facter::Util::Resolution.expand_command('foo.sh /a /b').should == %q{'/home/bob/my tools/foo.sh' /a /b}
        end

        it "should return nil if not found" do
          Facter::Util::Resolution.expects(:which).with('foo').returns nil
          Facter::Util::Resolution.expand_command('foo -a | stuff >> /dev/null').should be_nil
        end
      end
    end

  end

  # It's not possible, AFAICT, to mock %x{}, so I can't really test this bit.
  describe "when executing code" do
    it "should deprecate the interpreter parameter" do
      Facter.expects(:warnonce).with("The interpreter parameter to 'exec' is deprecated and will be removed in a future version.")
      Facter::Util::Resolution.exec("/something", "/bin/perl")
    end

    it "should execute the binary" do
      test_command = Facter::Util::Config.is_windows? ? 'cmd.exe /c echo foo' : 'echo foo'
      Facter::Util::Resolution.exec(test_command).should == "foo"
    end

    context "when run on unix", :as_platform => :posix  do
      context "binary is present" do
        it "should run the command if path to binary is absolute" do
          Facter::Util::Resolution.expects(:expand_command).with('/usr/bin/uname -m').returns('/usr/bin/uname -m')
          Facter::Util::Resolution.expects(:`).with('/usr/bin/uname -m').returns 'x86_64'
          Facter::Util::Resolution.exec('/usr/bin/uname -m').should == 'x86_64'
        end

        it "should run the expanded command if path to binary not absolute" do
          Facter::Util::Resolution.expects(:expand_command).with('uname -m').returns('/usr/bin/uname -m')
          Facter::Util::Resolution.expects(:`).with('/usr/bin/uname -m').returns 'x86_64'
          Facter::Util::Resolution.exec('uname -m').should == 'x86_64'
        end
      end

      context "binary is not present" do
        it "should not run the command if path to binary is absolute" do
          Facter::Util::Resolution.expects(:expand_command).with('/usr/bin/uname -m').returns nil
          Facter::Util::Resolution.expects(:`).with('/usr/bin/uname -m').never
          Facter::Util::Resolution.exec('/usr/bin/uname -m').should be_nil
        end
        it "should not run the command if path to binary is not absolute" do
          Facter::Util::Resolution.expects(:expand_command).with('uname -m').returns nil
          Facter::Util::Resolution.expects(:`).with('uname -m').never
          Facter::Util::Resolution.exec('uname -m').should be_nil
        end
      end
    end

    context "when run on windows", :as_platform => :windows do
      context "binary is present" do
        it "should run the command if path to binary is absolute" do
          Facter::Util::Resolution.expects(:expand_command).with(%q{C:\Windows\foo.exe /a /b}).returns(%q{C:\Windows\foo.exe /a /b})
          Facter::Util::Resolution.expects(:`).with(%q{C:\Windows\foo.exe /a /b}).returns 'bar'
          Facter::Util::Resolution.exec(%q{C:\Windows\foo.exe /a /b}).should == 'bar'
        end

        it "should run the expanded command if path to binary not absolute" do
          Facter::Util::Resolution.expects(:expand_command).with(%q{foo.exe /a /b}).returns(%q{C:\Windows\foo.exe /a /b})
          Facter::Util::Resolution.expects(:`).with(%q{C:\Windows\foo.exe /a /b}).returns 'bar'
          Facter::Util::Resolution.exec(%q{foo.exe /a /b}).should == 'bar'
        end
      end

      context "binary is not present" do
        it "should not run the command if path to binary is absolute" do
          Facter::Util::Resolution.expects(:expand_command).with(%q{C:\Windows\foo.exe /a /b}).returns nil
          Facter::Util::Resolution.expects(:`).with(%q{C:\Windows\foo.exe /a /b}).never
          Facter::Util::Resolution.exec(%q{C:\Windows\foo.exe /a /b}).should be_nil
        end
        it "should try to run the command and return output of a shell-builtin" do
          Facter::Util::Resolution.expects(:expand_command).with(%q{echo foo}).returns nil
          Facter::Util::Resolution.expects(:`).with(%q{echo foo}).returns 'foo'
          Facter.expects(:warnonce).with('Using Facter::Util::Resolution.exec with a shell built-in is deprecated. Most built-ins can be replaced with native ruby commands. If you really have to run a built-in, pass "cmd /c your_builtin" as a command')
          Facter::Util::Resolution.exec(%q{echo foo}).should == 'foo'
        end
        it "should try to run the command and return nil if not shell-builtin" do
          Facter::Util::Resolution.expects(:expand_command).with(%q{echo foo}).returns nil
          Facter::Util::Resolution.stubs(:`).with(%q{echo foo}).raises Errno::ENOENT, 'some_error_message'
          Facter.expects(:warnonce).never
          Facter::Util::Resolution.exec(%q{echo foo}).should be_nil
        end
      end
    end
  end
end
