# frozen_string_literal: true

describe Facter::FactsUtils::BytesConverter do
  describe '#to_mb' do
    it 'converts bytes to mega bytes' do
      expect(Facter::FactsUtils::BytesConverter.to_mb(256_586_343)).to eq(244.7)
    end

    it 'returns nil if value is nil' do
      expect(Facter::FactsUtils::BytesConverter.to_mb(nil)).to be(nil)
    end

    it 'returns nil if value is string' do
      expect(Facter::FactsUtils::BytesConverter.to_mb('2343455')).to be(nil)
    end

    it 'returns 0 if value is 0' do
      expect(Facter::FactsUtils::BytesConverter.to_mb(0)).to eq(0.0)
    end
  end
end
