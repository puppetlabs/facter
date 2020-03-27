require_relative '../../../spec_helper_legacy'

describe Facter::Core::Execution::Posix, unless: LegacyFacter::Util::Config.windows? do
  subject(:posix_executor) { Facter::Core::Execution::Posix.new }

  describe '#search_paths' do
    it 'uses the PATH environment variable plus /sbin and /usr/sbin on unix' do
      expect(ENV).to receive(:[]).with('PATH').and_return '/bin:/usr/bin'
      expect(posix_executor.search_paths). to eq %w[/bin /usr/bin /sbin /usr/sbin]
    end
  end

  describe '#which' do
    before do
      allow(posix_executor).to receive(:search_paths).and_return ['/bin', '/sbin', '/usr/sbin']
    end

    context 'and provided with an absolute path' do
      it 'returns the binary if executable' do
        expect(FileTest).to receive(:file?).with('/opt/foo').and_return true
        expect(File).to receive(:executable?).with('/opt/foo').and_return true
        expect(posix_executor.which('/opt/foo')).to eq '/opt/foo'
      end

      it 'returns nil if the binary is not executable' do
        expect(File).to receive(:executable?).with('/opt/foo').and_return false
        expect(posix_executor.which('/opt/foo')).to be nil
      end

      it 'returns nil if the binary is not a file' do
        expect(FileTest).to receive(:file?).with('/opt/foo').and_return false
        expect(File).to receive(:executable?).with('/opt/foo').and_return true
        expect(posix_executor.which('/opt/foo')).to be nil
      end
    end

    context 'and not provided with an absolute path' do
      it 'returns the absolute path if found' do
        expect(FileTest).not_to receive(:file?).with('/bin/foo')
        expect(File).to receive(:executable?).with('/bin/foo').and_return false
        expect(FileTest).to receive(:file?).with('/sbin/foo').and_return true
        expect(File).to receive(:executable?).with('/sbin/foo').and_return true
        expect(FileTest).not_to receive(:file?).with('/usr/sbin/foo')
        expect(File).not_to receive(:executable?).with('/usr/sbin/foo')
        expect(posix_executor.which('foo')).to eq '/sbin/foo'
      end

      it 'returns nil if not found' do
        expect(File).to receive(:executable?).with('/bin/foo').and_return false
        expect(File).to receive(:executable?).with('/sbin/foo').and_return false
        expect(File).to receive(:executable?).with('/usr/sbin/foo').and_return false
        expect(posix_executor.which('foo')).to be nil
      end
    end
  end

  describe '#expand_command' do
    it 'expands binary' do
      expect(posix_executor).to receive(:which).with('foo').and_return '/bin/foo'
      expect(posix_executor.expand_command('foo -a | stuff >> /dev/null')).to eq '/bin/foo -a | stuff >> /dev/null'
    end

    it 'expands double quoted binary' do
      expect(posix_executor).to receive(:which).with('/tmp/my foo').and_return '/tmp/my foo'
      expect(posix_executor.expand_command('"/tmp/my foo" bar')).to eq "'/tmp/my foo' bar"
    end

    it 'expands single quoted binary' do
      expect(posix_executor).to receive(:which).with('my foo').and_return '/home/bob/my path/my foo'
      expect(posix_executor.expand_command("'my foo' -a")).to eq "'/home/bob/my path/my foo' -a"
    end

    it 'quotes expanded binary if found in path with spaces' do
      expect(posix_executor).to receive(:which).with('foo.sh').and_return '/home/bob/my tools/foo.sh'
      expect(posix_executor.expand_command('foo.sh /a /b')).to eq "'/home/bob/my tools/foo.sh' /a /b"
    end

    it 'returns nil if not found' do
      expect(posix_executor).to receive(:which).with('foo').and_return nil
      expect(posix_executor.expand_command('foo -a | stuff >> /dev/null')).to be nil
    end
  end

  describe '#absolute_path?' do
    %w[/ /foo /foo/../bar //foo //Server/Foo/Bar //?/C:/foo/bar /\Server/Foo /foo//bar/baz].each do |path|
      it "returns true for #{path}" do
        expect(posix_executor).to be_absolute_path(path)
      end
    end

    %w[. ./foo \foo C:/foo \\Server\Foo\Bar \\?\C:\foo\bar \/?/foo\bar \/Server/foo foo//bar/baz].each do |path|
      it "returns false for #{path}" do
        expect(posix_executor).not_to be_absolute_path(path)
      end
    end
  end
end
