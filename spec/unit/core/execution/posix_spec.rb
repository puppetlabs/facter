require 'spec_helper'
require 'facter/util/config'

describe Facter::Core::Execution::Posix, :unless => Facter::Util::Config.is_windows? do
  describe "#search_paths" do
    it "should use the PATH environment variable plus /sbin and /usr/sbin on unix" do
      ENV.expects(:[]).with('PATH').returns "/bin:/usr/bin"
      subject.search_paths.should == %w{/bin /usr/bin /sbin /usr/sbin}
    end
  end

  describe "#which" do
    before :each do
      subject.stubs(:search_paths).returns [ '/bin', '/sbin', '/usr/sbin']
    end

    context "and provided with an absolute path" do
      it "should return the binary if executable" do
        File.expects(:file?).with('/opt/foo').returns true
        File.expects(:executable?).with('/opt/foo').returns true
        subject.which('/opt/foo').should == '/opt/foo'
      end

      it "should return nil if the binary is not executable" do
        File.expects(:executable?).with('/opt/foo').returns false
        subject.which('/opt/foo').should be_nil
      end

      it "should return nil if the binary is not a file" do
        File.expects(:file?).with('/opt/foo').returns false
        File.expects(:executable?).with('/opt/foo').returns true
        subject.which('/opt/foo').should be_nil
      end
    end

    context "and not provided with an absolute path" do
      it "should return the absolute path if found" do
        File.expects(:file?).with('/bin/foo').never
        File.expects(:executable?).with('/bin/foo').returns false
        File.expects(:file?).with('/sbin/foo').returns true
        File.expects(:executable?).with('/sbin/foo').returns true
        File.expects(:file?).with('/usr/sbin/foo').never
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

  describe "#expand_command" do
    it "should expand binary" do
      subject.expects(:which).with('foo').returns '/bin/foo'
      subject.expand_command('foo -a | stuff >> /dev/null').should == '/bin/foo -a | stuff >> /dev/null'
    end

    it "should expand double quoted binary" do
      subject.expects(:which).with('/tmp/my foo').returns '/tmp/my foo'
      subject.expand_command(%q{"/tmp/my foo" bar}).should == %q{'/tmp/my foo' bar}
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

  describe "#absolute_path?" do
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
end
