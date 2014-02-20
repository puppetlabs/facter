require 'spec_helper'

describe Facter::Core::Execution::Windows, :as_platform => :windows do

  describe "#search_paths" do
    it "should use the PATH environment variable to determine locations" do
      ENV.expects(:[]).with('PATH').returns 'C:\Windows;C:\Windows\System32'
      subject.search_paths.should == %w{C:\Windows C:\Windows\System32}
    end
  end

  describe "#which" do
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
      subject.expand_command('foo /a | stuff >> NUL').should be_nil
    end
  end

  describe "#absolute_path?" do
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
