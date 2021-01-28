# frozen_string_literal: true

describe Facter::Util::Facts::UnitConverter do
  subject(:converter) { Facter::Util::Facts::UnitConverter }

  describe '#bytes_to_mb' do
    it 'converts bytes to mega bytes' do
      expect(converter.bytes_to_mb(256_586_343)).to eq(244.7)
    end

    it 'returns nil if value is nil' do
      expect(converter.bytes_to_mb(nil)).to be(nil)
    end

    it 'converts bytes if value is string' do
      expect(converter.bytes_to_mb('2343455')).to eq(2.23)
    end

    it 'returns 0 if value is 0' do
      expect(converter.bytes_to_mb(0)).to eq(0.0)
    end
  end

  describe '#hertz_to_human_readable' do
    it 'returns nil if value is 0' do
      expect(converter.hertz_to_human_readable(0)).to be_nil
    end

    it 'returns nil if value is string' do
      expect(converter.hertz_to_human_readable('test')).to be_nil
    end

    it 'converts to GHz' do
      expect(converter.hertz_to_human_readable(2_300_000_000)).to eql('2.30 GHz')
    end

    it 'converts to MHz' do
      expect(converter.hertz_to_human_readable(800_000_000)).to eql('800.00 MHz')
    end

    it 'handles small-ish number correctly' do
      expect(converter.hertz_to_human_readable(42)).to eql('42.00 Hz')
    end

    it 'converts to Hz even if argument is string' do
      expect(converter.hertz_to_human_readable('2400')).to eql('2.40 kHz')
    end
  end

  describe '#bytes_to_human_readable' do
    it 'returns nil if bytes variable is nil' do
      expect(converter.bytes_to_human_readable(nil)).to be(nil)
    end

    it 'returns next unit if result is 1024 after conversion' do
      expect(converter.bytes_to_human_readable(1_048_575.7)).to eql('1.00 MiB')
    end

    it 'returns bytes if bytes variable is less than 1024' do
      expect(converter.bytes_to_human_readable(1023)).to eql('1023 bytes')
    end

    it 'returns 1 Kib if bytes variable equals 1024' do
      expect(converter.bytes_to_human_readable(1024)).to eql('1.00 KiB')
    end

    it 'returns bytes if number exceeds etta bytes' do
      expect(converter.bytes_to_human_readable(3_296_472_651_763_232_323_235)).to eql('3296472651763232323235 bytes')
    end
  end

  describe '#pad_number' do
    it 'appends a 0 when conversion has one decimal digit' do
      expect(converter.send(:pad_number, 10.0)).to eql('10.00')
    end

    it 'leaves the value unmodified if it has two decimals' do
      expect(converter.send(:pad_number, 10.23)).to eql('10.23')
    end
  end
end
