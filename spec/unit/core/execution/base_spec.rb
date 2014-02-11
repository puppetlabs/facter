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

  describe "#search_paths" do
    context "on windows", :as_platform => :windows do
      it "should use the PATH environment variable to determine locations" do
        ENV.expects(:[]).with('PATH').returns 'C:\Windows;C:\Windows\System32'
        subject.search_paths.should == %w{C:\Windows C:\Windows\System32}
      end
    end

    context "on posix", :as_platform => :posix do
      it "should use the PATH environment variable plus /sbin and /usr/sbin on unix" do
        ENV.expects(:[]).with('PATH').returns "/bin:/usr/bin"
        subject.search_paths.should == %w{/bin /usr/bin /sbin /usr/sbin}
      end
    end
  end

  describe "#which" do
    context "when run on posix", :as_platform => :posix  do
      before :each do
        subject.stubs(:search_paths).returns [ '/bin', '/sbin', '/usr/sbin']
      end

      context "and provided with an absolute path" do
        it "should return the binary if executable" do
          File.expects(:executable?).with('/opt/foo').returns true
          subject.which('/opt/foo').should == '/opt/foo'
        end

        it "should return nil if the binary is not executable" do
          File.expects(:executable?).with('/opt/foo').returns false
          subject.which('/opt/foo').should be_nil
        end
      end

      context "and not provided with an absolute path" do
        it "should return the absolute path if found" do
          File.expects(:executable?).with('/bin/foo').returns false
          File.expects(:executable?).with('/sbin/foo').returns true
          File.expects(:executable?).with('/usr/sbin/foo').never
          subject.which('foo').should == '/sbin/foo'
        end

        it "should return nil if not found" do
          File.expects(:executable?).with('/bin/foo').returns false
          File.expects(:executable?).with('/sbin/foo').returns false
          File.expects(:executable?).with('/usr/sbin/foo').returns false
          subject.which('foo').should be_nil
        end
      end
    end

    context "when run on windows", :as_platform => :windows do
      before :each do
        subject.stubs(:search_paths).returns ['C:\Windows\system32', 'C:\Windows', 'C:\Windows\System32\Wbem' ]
        ENV.stubs(:[]).with('PATHEXT').returns nil
      end

      context "and provided with an absolute path" do
        it "should return the binary if executable" do
          File.expects(:executable?).with('C:\Tools\foo.exe').returns true
          File.expects(:executable?).with('\\\\remote\dir\foo.exe').returns true
          subject.which('C:\Tools\foo.exe').should == 'C:\Tools\foo.exe'
          subject.which('\\\\remote\dir\foo.exe').should == '\\\\remote\dir\foo.exe'
        end

        it "should return nil if the binary is not executable" do
          File.expects(:executable?).with('C:\Tools\foo.exe').returns false
          File.expects(:executable?).with('\\\\remote\dir\foo.exe').returns false
          subject.which('C:\Tools\foo.exe').should be_nil
          subject.which('\\\\remote\dir\foo.exe').should be_nil
        end
      end

      context "and not provided with an absolute path" do
        it "should return the absolute path if found" do
          File.expects(:executable?).with('C:\Windows\system32\foo.exe').returns false
          File.expects(:executable?).with('C:\Windows\foo.exe').returns true
          File.expects(:executable?).with('C:\Windows\System32\Wbem\foo.exe').never
          subject.which('foo.exe').should == 'C:\Windows\foo.exe'
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

          subject.which('foo').should == 'C:\Windows\foo.EXE'
        end

        it "should return nil if not found" do
          File.expects(:executable?).with('C:\Windows\system32\foo.exe').returns false
          File.expects(:executable?).with('C:\Windows\foo.exe').returns false
          File.expects(:executable?).with('C:\Windows\System32\Wbem\foo.exe').returns false
          subject.which('foo.exe').should be_nil
        end
      end
    end

    describe "#expand_command" do
      context "on windows", :as_platform => :windows do
        it "should expand binary" do
          subject.expects(:which).with('cmd').returns 'C:\Windows\System32\cmd'
          subject.expand_command(
            'cmd /c echo foo > C:\bar'
          ).should == 'C:\Windows\System32\cmd /c echo foo > C:\bar'
        end

        it "should expand double quoted binary" do
          subject.expects(:which).with('my foo').returns 'C:\My Tools\my foo.exe'
          subject.expand_command('"my foo" /a /b').should == '"C:\My Tools\my foo.exe" /a /b'
        end

        it "should not expand single quoted binary" do
          subject.expects(:which).with('\'C:\My').returns nil
          subject.expand_command('\'C:\My Tools\foo.exe\' /a /b').should be_nil
        end

        it "should quote expanded binary if found in path with spaces" do
          subject.expects(:which).with('foo').returns 'C:\My Tools\foo.exe'
          subject.expand_command('foo /a /b').should == '"C:\My Tools\foo.exe" /a /b'
        end

        it "should return nil if not found" do
          subject.expects(:which).with('foo').returns nil
          subject.expand_command('foo /a | stuff >> /dev/null').should be_nil
        end
      end

      context "on unix", :as_platform => :posix do
        it "should expand binary" do
          subject.expects(:which).with('foo').returns '/bin/foo'
          subject.expand_command('foo -a | stuff >> /dev/null').should == '/bin/foo -a | stuff >> /dev/null'
        end

        it "should expand double quoted binary" do
          subject.expects(:which).with('/tmp/my foo').returns '/tmp/my foo'
          subject.expand_command(%q{"/tmp/my foo" bar}).should == %q{"/tmp/my foo" bar}
        end

        it "should expand single quoted binary" do
          subject.expects(:which).with('my foo').returns '/home/bob/my path/my foo'
          subject.expand_command(%q{'my foo' -a}).should == %q{'/home/bob/my path/my foo' -a}
        end

        it "should quote expanded binary if found in path with spaces" do
          subject.expects(:which).with('foo.sh').returns '/home/bob/my tools/foo.sh'
          subject.expand_command('foo.sh /a /b').should == %q{'/home/bob/my tools/foo.sh' /a /b}
        end

        it "should return nil if not found" do
          subject.expects(:which).with('foo').returns nil
          subject.expand_command('foo -a | stuff >> /dev/null').should be_nil
        end
      end
    end

  end

  describe "#absolute_path?" do
    context "when run on unix", :as_platform => :posix do
      %w[/ /foo /foo/../bar //foo //Server/Foo/Bar //?/C:/foo/bar /\Server/Foo /foo//bar/baz].each do |path|
        it "should return true for #{path}" do
          subject.should be_absolute_path(path)
        end
      end

      %w[. ./foo \foo C:/foo \\Server\Foo\Bar \\?\C:\foo\bar \/?/foo\bar \/Server/foo foo//bar/baz].each do |path|
        it "should return false for #{path}" do
          subject.should_not be_absolute_path(path)
        end
      end
    end

    context "when run on windows", :as_platform => :windows  do
      %w[C:/foo C:\foo \\\\Server\Foo\Bar \\\\?\C:\foo\bar //Server/Foo/Bar //?/C:/foo/bar /\?\C:/foo\bar \/Server\Foo/Bar c:/foo//bar//baz].each do |path|
        it "should return true for #{path}" do
          subject.should be_absolute_path(path)
        end
      end

      %w[/ . ./foo \foo /foo /foo/../bar //foo C:foo/bar foo//bar/baz].each do |path|
        it "should return false for #{path}" do
          subject.should_not be_absolute_path(path)
        end
      end
    end
  end
end
