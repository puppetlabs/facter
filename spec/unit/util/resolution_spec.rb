#!/usr/bin/env rspec

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
        @resolve.expects(:warn)
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
    describe "when run on unix" do
      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns false
      end

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

    describe "when run on windows" do
      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns true
      end

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
    it "should use the PATH evironment variable to determine locations on windows" do
      # The reason for hacking the PATH_SEPARATOR constant is that
      # a single path like C:\Windows already contains the unix PATH_SEPARATOR
      # and splitting would be wrong. The other way around works because unix
      # pathes normallay do not contain the windows PATH_SEPARATOR
      old_separator = File::PATH_SEPARATOR
      Facter::Util::Config.stubs(:is_windows?).returns true
      ENV.expects(:[]).with('PATH').returns 'C:\Windows;C:\Windows\System32'
      File.send(:remove_const,'PATH_SEPARATOR')
      File.const_set('PATH_SEPARATOR', ';')
      begin
        Facter::Util::Resolution.search_paths.should == %w{C:\Windows C:\Windows\System32}
      ensure
        File.send(:remove_const,'PATH_SEPARATOR')
        File.const_set('PATH_SEPARATOR', old_separator)
      end
    end

    it "should use the PATH environment variable plus /sbin and /usr/sbin on unix" do
      Facter::Util::Config.stubs(:is_windows?).returns false
      ENV.expects(:[]).with('PATH').returns "/bin#{File::PATH_SEPARATOR}/usr/bin"
      Facter::Util::Resolution.search_paths.should == %w{/bin /usr/bin /sbin /usr/sbin}
    end
  end

  describe "#which" do
    describe "when run on unix" do
      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns false
        Facter::Util::Resolution.stubs(:search_paths).returns [ '/bin', '/sbin', '/usr/sbin']
      end

      describe "and provided with an absolute path" do
        it "should return the binary if executable" do
          File.expects(:executable?).with('/opt/foo').returns true
          Facter::Util::Resolution.which('/opt/foo').should == '/opt/foo'
        end

        it "should return nil if the binary is not executable" do
          File.expects(:executable?).with('/opt/foo').returns false
          Facter::Util::Resolution.which('/opt/foo').should be_nil
        end
      end

      describe "and not provided with an absolute path" do
        it "should return the absolute path if found" do
          File.expects(:executable?).with(File.join('/bin','foo')).returns false
          File.expects(:executable?).with(File.join('/sbin','foo')).returns true
          File.expects(:executable?).with(File.join('/usr/sbin','foo')).never
          Facter::Util::Resolution.which('foo').should == File.join('/sbin','foo')
        end

        it "should return nil if not found" do
          File.expects(:executable?).with(File.join('/bin','foo')).returns false
          File.expects(:executable?).with(File.join('/sbin','foo')).returns false
          File.expects(:executable?).with(File.join('/usr/sbin','foo')).returns false
          Facter::Util::Resolution.which('foo').should be_nil
        end
      end
    end

    describe "when run on windows" do
      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns true
        Facter::Util::Resolution.stubs(:search_paths).returns ['C:\Windows\system32', 'C:\Windows', 'C:\Windows\System32\Wbem' ]
      end

      describe "and provided with an absolute path" do
        it "should return the binary if executable" do
          File.expects(:executable?).with('C:\Tools\foo.exe').returns true
          File.expects(:executable?).with('\\\\remote\dir\foo.exe').returns true
          Facter::Util::Resolution.which('C:\Tools\foo.exe').should == 'C:\Tools\foo.exe'
          Facter::Util::Resolution.which('\\\\remote\dir\foo.exe').should == '\\\\remote\dir\foo.exe'
        end

        it "should return nil if the binary is not executable" do
          File.expects(:executable?).with('C:\Tools\foo.exe').returns false
          File.expects(:executable?).with('\\\\remote\dir\foo.exe').returns false
          Facter::Util::Resolution.which('C:\Tools\foo.exe').should be_nil
          Facter::Util::Resolution.which('\\\\remote\dir\foo.exe').should be_nil
        end
      end

      describe "and not provided with an absolute path" do
        it "should return the absolute path if found" do
          File.expects(:executable?).with(File.join('C:\Windows\system32','foo.exe')).returns false
          File.expects(:executable?).with(File.join('C:\Windows','foo.exe')).returns true
          File.expects(:executable?).with(File.join('C:\Windows\System32\Wbem', 'foo.exe')).never
          Facter::Util::Resolution.which('foo.exe').should == File.join('C:\Windows','foo.exe')
        end

        it "should return the absolute path with file extension if found" do
          ENV.stubs(:[]).with('PATHEXT').returns nil
          ['.COM', '.EXE', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with(File.join('C:\Windows\system32',"foo#{ext}")).returns false
            File.stubs(:executable?).with(File.join('C:\Windows\System32\Wbem',"foo#{ext}")).returns false
          end
          ['.COM', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with(File.join('C:\Windows',"foo#{ext}")).returns false
          end
          File.stubs(:executable?).with(File.join('C:\Windows',"foo.EXE")).returns true

          Facter::Util::Resolution.which('foo').should == File.join('C:\Windows','foo.EXE')
        end

        it "should return nil if not found" do
          File.expects(:executable?).with(File.join('C:\Windows\system32','foo.exe')).returns false
          File.expects(:executable?).with(File.join('C:\Windows','foo.exe')).returns false
          File.expects(:executable?).with(File.join('C:\Windows\System32\Wbem', 'foo.exe')).returns false
          Facter::Util::Resolution.which('foo.exe').should be_nil
        end
      end
    end

    describe "#expand_command" do
      it "should expand binary" do
        Facter::Util::Resolution.expects(:which).with('foo').returns '/bin/foo'
        Facter::Util::Resolution.expand_command('foo -a | stuff >> /dev/null').should == '/bin/foo -a | stuff >> /dev/null'
      end

      it "should expand single quoted binary on unix" do
        Facter::Util::Config.stubs(:is_windows?).returns false
        Facter::Util::Resolution.expects(:which).with('my foo').returns '/home/bob/my path/my foo'
        Facter::Util::Resolution.expand_command('\'my foo\' -a').should == '\'/home/bob/my path/my foo\' -a'
      end

      it "should not expand single quoted binary on windows" do
        Facter::Util::Config.stubs(:is_windows?).returns true
        Facter::Util::Resolution.expects(:which).with('\'C:\My').returns nil
        Facter::Util::Resolution.expand_command('\'C:\My Tools\foo.exe\' /a /b').should == nil
      end

      it "should expand double quoted binary on unix" do
        Facter::Util::Config.stubs(:is_windows?).returns false
        Facter::Util::Resolution.expects(:which).with('my foo').returns '/home/bob/my path/my foo'
        Facter::Util::Resolution.expand_command('"my foo" -a').should == '"/home/bob/my path/my foo" -a'
      end

      it "should expand double quoted binary on windows" do
        Facter::Util::Config.stubs(:is_windows?).returns true
        Facter::Util::Resolution.expects(:which).with('C:\My Tools\foo.exe').returns 'C:\My Tools\foo.exe'
        Facter::Util::Resolution.expand_command('"C:\My Tools\foo.exe" /a /b').should == '"C:\My Tools\foo.exe" /a /b'
      end

      it "should escape spaces in path" do
        Facter::Util::Resolution.expects(:which).with('foo.exe').returns 'C:\My Tools\foo.exe'
        Facter::Util::Resolution.expand_command('foo.exe /a /b').should == '"C:\My Tools\foo.exe" /a /b'
      end

      it "should return nil if not found" do
        Facter::Util::Resolution.expects(:which).with('foo').returns nil
        Facter::Util::Resolution.expand_command('foo -a | stuff >> /dev/null').should be_nil
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
      Facter::Util::Resolution.exec("echo foo").should == "foo"
    end

    describe "when run on unix" do
      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns false
      end

      describe "and the binary is an absolute path" do
        it "should run the command if the binary is found" do
          File.expects(:executable?).with('/usr/bin/uname').returns true
          Facter::Util::Resolution.expects(:`).with('/usr/bin/uname -a').returns "x86_64\n"
          Facter::Util::Resolution.exec('/usr/bin/uname -a').should == 'x86_64'
        end

        # taken from the ip fact
        it "should run more complicated shell expression" do
          File.expects(:executable?).with('/sbin/arp').returns true
          Facter::Util::Resolution.expects(:`).with('/sbin/arp -en -i eth0 | sed -e 1d').returns "some_data\n"
          Facter::Util::Resolution.exec('/sbin/arp -en -i eth0 | sed -e 1d').should == 'some_data'
        end

        it "should not run the command if the binary is not present" do
          File.expects(:executable?).with('/usr/bin/uname').returns false
          Facter::Util::Resolution.expects(:`).with('/usr/bin/uname -a').never
          Facter::Util::Resolution.exec('/usr/bin/uname -a').should be_nil
        end
      end

      describe "and the binary is a relative path" do
        it "should always include /sbin and /usr/sbin in search path" do
          Facter::Util::Resolution.search_paths.should include '/sbin'
          Facter::Util::Resolution.search_paths.should include '/usr/sbin'
        end

        it "should run the command if found in search path" do
          Facter::Util::Resolution.stubs(:search_paths).returns ['/sbin', '/bin' ]
          File.stubs(:executable?).with(File.join('/sbin','ifconfig')).returns false
          File.stubs(:executable?).with(File.join('/bin','ifconfig')).returns true
          Facter::Util::Resolution.expects(:`).with(File.join('/bin','ifconfig -a')).returns "done\n"
          Facter::Util::Resolution.exec('ifconfig -a').should == 'done'
        end

        it "should not run the command if not found in any search path" do
          Facter::Util::Resolution.stubs(:search_paths).returns ['/sbin', '/bin' ]
          File.stubs(:executable?).with(File.join('/sbin','ifconfig')).returns false
          File.stubs(:executable?).with(File.join('/bin','ifconfig')).returns false
          Facter::Util::Resolution.exec('ifconfig -a').should be_nil
        end
      end
    end

    describe "when run on windows" do
      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns true
      end

      describe "and the binary is an absolute path" do
        it "should run the command if the binary is found" do
          File.expects(:executable?).with('C:\foo\bar.exe').returns true
          Facter::Util::Resolution.expects(:`).with('C:\foo\bar.exe /a /b /c "foo bar.txt"').returns "done\n"
          Facter::Util::Resolution.exec('C:\foo\bar.exe /a /b /c "foo bar.txt"').should == 'done'
        end

        it "should handle quoted binaries with spaces correctly" do
          File.expects(:executable?).with('C:\foo baz\bar.exe').returns true
          Facter::Util::Resolution.expects(:`).with('"C:\foo baz\bar.exe" /a /b /c "foo bar.txt"').returns "done\n"
          Facter::Util::Resolution.exec('"C:\foo baz\bar.exe" /a /b /c "foo bar.txt"').should == 'done'
        end

        it "should not run the command if the binary is not found" do
          File.expects(:executable?).with('C:\foo\bar.exe').returns false
          Facter::Util::Resolution.expects(:`).with('C:\foo\bar.exe /a /b /c "foo bar.txt"').never
          Facter::Util::Resolution.exec('C:\foo\bar.exe /a /b /c "foo bar.txt"').should be_nil
        end
      end

      describe "and the binary is a relative path" do
        it "should run the command if found in search path" do
          Facter::Util::Resolution.stubs(:search_paths).returns ['C:\Windows\system32', 'C:\Windows', 'C:\Windows\System32\Wbem' ]
          File.stubs(:executable?).with(File.join('C:\Windows\system32','foo.exe')).returns false
          File.stubs(:executable?).with(File.join('C:\Windows','foo.exe')).returns true
          File.stubs(:executable?).with(File.join('C:\Windows\System32\Wbem', 'foo.exe')).returns false
          Facter::Util::Resolution.expects(:`).with(File.join('C:\Windows','foo.exe')).returns "done\n"
          Facter::Util::Resolution.exec('foo.exe').should == 'done'
        end

        it "should try to find the correct extension" do
          ENV.stubs(:[]).with('PATHEXT').returns nil
          Facter::Util::Resolution.stubs(:search_paths).returns ['C:\Windows\system32', 'C:\Windows']
          ['.COM', '.EXE', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with(File.join('C:\Windows\system32',"foo#{ext}")).returns false
          end
          ['.COM', '.BAT', '.CMD', '' ].each do |ext|
            File.stubs(:executable?).with(File.join('C:\Windows',"foo#{ext}")).returns false
          end
          File.stubs(:executable?).with(File.join('C:\Windows',"foo.EXE")).returns true
          Facter::Util::Resolution.expects(:`).with(File.join('C:\Windows','foo.EXE')).returns "done\n"
          Facter::Util::Resolution.exec('foo').should == 'done'
        end

        it "should not run the command if not found in any search path" do
          Facter::Util::Resolution.stubs(:search_paths).returns ['C:\Windows\system32', 'C:\Windows', 'C:\Windows\System32\Wbem' ]
          File.stubs(:executable?).with(File.join('C:\Windows\system32','foo.exe')).returns false
          File.stubs(:executable?).with(File.join('C:\Windows','foo.exe')).returns false
          File.stubs(:executable?).with(File.join('C:\Windows\System32\Wbem', 'foo.exe')).returns false
          Facter::Util::Resolution.exec('foo.exe').should be_nil
        end
      end
    end
  end
end
