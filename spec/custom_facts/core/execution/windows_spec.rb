require_relative '../../../spec_helper_legacy'

describe LegacyFacter::Core::Execution::Windows, as_platform: :windows do
  describe '#search_paths' do
    it 'uses the PATH environment variable to determine locations' do
      allow(ENV).to receive(:[]).with('PATH').and_return 'C:\Windows;C:\Windows\System32'
      expect(subject.search_paths).to eq %w[C:\Windows C:\Windows\System32]
    end
  end

  describe '#execute' do
    context 'with expand false' do
      subject(:executor) { LegacyFacter::Core::Execution::Windows.new }

      it 'raises exception' do
        expect { executor.execute('c:\foo.exe', expand: false) }
          .to raise_error(ArgumentError,
                          'Unsupported argument on Windows expand with value false')
      end
    end
  end

  describe '#which' do
    before do
      allow(subject)
        .to receive(:search_paths)
        .and_return ['C:\Windows\system32', 'C:\Windows', 'C:\Windows\System32\Wbem']
      allow(ENV).to receive(:[]).with('PATHEXT').and_return nil
    end

    context 'and provided with an absolute path' do
      it 'returns the binary if executable' do
        expect(File).to receive(:executable?).with('C:\Tools\foo.exe').and_return true
        expect(File).to receive(:executable?).with('\\\\remote\dir\foo.exe').and_return true

        expect(subject.which('C:\Tools\foo.exe')).to eq 'C:\Tools\foo.exe'
        expect(subject.which('\\\\remote\dir\foo.exe')).to eq '\\\\remote\dir\foo.exe'
      end

      it 'returns nil if the binary is not executable' do
        expect(File).to receive(:executable?).with('C:\Tools\foo.exe').and_return false
        expect(File).to receive(:executable?).with('\\\\remote\dir\foo.exe').and_return false

        expect(subject.which('C:\Tools\foo.exe')).to be nil
        expect(subject.which('\\\\remote\dir\foo.exe')).to be nil
      end
    end

    context 'and not provided with an absolute path' do
      it 'returns the absolute path if found' do
        expect(File).to receive(:executable?).with('C:\Windows\system32\foo.exe').and_return false
        expect(File).to receive(:executable?).with('C:\Windows\foo.exe').and_return true
        expect(File).not_to receive(:executable?).with('C:\Windows\System32\Wbem\foo.exe')

        expect(subject.which('foo.exe')).to eq 'C:\Windows\foo.exe'
      end

      it 'returns the absolute path with file extension if found' do
        ['.COM', '.EXE', '.BAT', '.CMD', ''].each do |ext|
          allow(File).to receive(:executable?).with('C:\Windows\system32\foo' + ext).and_return false
          allow(File).to receive(:executable?).with('C:\Windows\System32\Wbem\foo' + ext).and_return false
        end
        ['.COM', '.BAT', '.CMD', ''].each do |ext|
          allow(File).to receive(:executable?).with('C:\Windows\foo' + ext).and_return false
        end
        allow(File).to receive(:executable?).with('C:\Windows\foo.EXE').and_return true

        expect(subject.which('foo')).to eq 'C:\Windows\foo.EXE'
      end

      it 'returns nil if not found' do
        allow(File).to receive(:executable?).with('C:\Windows\system32\foo.exe').and_return false
        allow(File).to receive(:executable?).with('C:\Windows\foo.exe').and_return false
        allow(File).to receive(:executable?).with('C:\Windows\System32\Wbem\foo.exe').and_return false

        expect(subject.which('foo.exe')).to be nil
      end
    end
  end

  describe '#expand_command' do
    it 'expands binary' do
      expect(subject).to receive(:which).with('cmd').and_return 'C:\Windows\System32\cmd'

      expect(subject.expand_command(
               'cmd /c echo foo > C:\bar'
             )).to eq 'C:\Windows\System32\cmd /c echo foo > C:\bar'
    end

    it 'expands double quoted binary' do
      expect(subject).to receive(:which).with('my foo').and_return 'C:\My Tools\my foo.exe'
      expect(subject.expand_command('"my foo" /a /b')).to eq '"C:\My Tools\my foo.exe" /a /b'
    end

    it 'does not expand single quoted binary' do
      expect(subject).to receive(:which).with('\'C:\My').and_return nil
      expect(subject.expand_command('\'C:\My Tools\foo.exe\' /a /b')).to be nil
    end

    it 'quotes expanded binary if found in path with spaces' do
      expect(subject).to receive(:which).with('foo').and_return 'C:\My Tools\foo.exe'
      expect(subject.expand_command('foo /a /b')).to eq '"C:\My Tools\foo.exe" /a /b'
    end

    it 'returns nil if not found' do
      expect(subject).to receive(:which).with('foo').and_return nil
      expect(subject.expand_command('foo /a | stuff >> NUL')).to be nil
    end
  end

  describe '#absolute_path?' do
    ['C:/foo',
     'C:\foo',
     '\\\\Server\Foo\Bar',
     '\\\\?\C:\foo\bar',
     '//Server/Foo/Bar',
     '//?/C:/foo/bar',
     '/\?\C:/foo\bar',
     '\/Server\Foo/Bar',
     'c:/foo//bar//baz'].each do |path|
      it "returns true for #{path}" do
        expect(subject).to be_absolute_path(path)
      end
    end

    %w[/ . ./foo \foo /foo /foo/../bar //foo C:foo/bar foo//bar/baz].each do |path|
      it "returns false for #{path}" do
        expect(subject).not_to be_absolute_path(path)
      end
    end
  end
end
