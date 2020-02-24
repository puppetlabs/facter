# frozen_string_literal: true

describe Facter::BytesToHumanReadable do
  describe '.convert' do
    it 'returns nil if bytes variable is nil' do
      expect(Facter::BytesToHumanReadable.convert(nil)).to be(nil)
    end

    it 'returns next unit if result is 1024 after conversion' do
      expect(Facter::BytesToHumanReadable.convert(1_048_575.7)).to eql('1.00 MiB')
    end

    it 'returns bytes if bytes variable is less than 1024' do
      expect(Facter::BytesToHumanReadable.convert(1023)).to eql('1023 bytes')
    end

    it 'returns 1 Kib if bytes variable equals 1024' do
      expect(Facter::BytesToHumanReadable.convert(1024)).to eql('1.00 KiB')
    end

    it 'returns bytes if number exceeds etta bytes' do
      expect(Facter::BytesToHumanReadable.convert(3_296_472_651_763_232_323_235)).to eql('3296472651763232323235 bytes')
    end
  end

  describe '.pad_number' do
    it 'appends a 0 when conversion has one decimal digit' do
      expect(Facter::BytesToHumanReadable.send(:pad_number, 10.0)).to eql('10.00')
    end

    it 'leaves the value unmodified if it has two decimals' do
      expect(Facter::BytesToHumanReadable.send(:pad_number, 10.23)).to eql('10.23')
    end
  end
end
