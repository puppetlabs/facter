# frozen_string_literal: true

describe Facter::Utils do
  let(:hash_to_change) { { this: { is: [{ 1 => 'test' }] } } }
  let(:result) { { 'this' => { 'is' => [{ '1' => 'test' }] } } }

  describe '.deep_stringify_keys' do
    it 'stringifies keys in hash' do
      expect(Facter::Utils.deep_stringify_keys(hash_to_change)).to eql(result)
    end
  end

  describe '.try_to_bool' do
    it 'converts to bool when truthy' do
      expect(Facter::Utils.try_to_bool('true')).to be true
    end

    it 'converts to bool when falsey' do
      expect(Facter::Utils.try_to_bool('false')).to be false
    end

    it 'leaves the string unchanged otherwise' do
      expect(Facter::Utils.try_to_bool('something else')).to eql('something else')
    end
  end
end
