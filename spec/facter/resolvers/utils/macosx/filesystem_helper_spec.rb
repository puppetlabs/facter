# frozen_string_literal: true

describe Facter::FilesystemHelper do
  describe '.compute_capacity' do
    it 'returns an integer if full' do
      capacity = described_class.send(:compute_capacity, 100, 100)
      expect(capacity).to eq('100%')
    end

    it 'returns an integer if empty' do
      capacity = described_class.send(:compute_capacity, 0, 100)
      expect(capacity).to eq('0%')
    end

    it 'returns a ratio with 2 decimals otherwise' do
      capacity = described_class.send(:compute_capacity, 421, 10_000)
      expect(capacity).to eq('4.21%')
    end
  end
end
