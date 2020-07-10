# frozen_string_literal: true

describe Facter::Utils do
  let(:hash_to_change) { { this: { is: [{ 1 => 'test' }] } } }
  let(:result) { { 'this' => { 'is' => [{ '1' => 'test' }] } } }

  describe '#deep_stringify_keys' do
    it 'stringify keys in hash' do
      expect(Facter::Utils.deep_stringify_keys(hash_to_change)).to eql(result)
    end
  end
end
