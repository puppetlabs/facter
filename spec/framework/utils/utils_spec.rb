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

  describe '.try_to_int' do
    context 'when possible, converts to int' do
      it 'leaves int as it is' do
        expect(Facter::Utils.try_to_int(7)).to be(7)
      end

      it 'converts string int' do
        expect(Facter::Utils.try_to_int('7')).to be(7)
      end

      it 'converts positive string int' do
        expect(Facter::Utils.try_to_int('+7')).to be(7)
      end

      it 'converts negative string int' do
        expect(Facter::Utils.try_to_int('-7')).to be(-7)
      end

      it 'converts float' do
        expect(Facter::Utils.try_to_int(7.10)).to be(7)
      end
    end

    context 'when not possible, does not convert to int' do
      it 'does not convert non-numerical string' do
        expect(Facter::Utils.try_to_int('string')).to be('string')
      end

      it 'does not convert partial string int' do
        expect(Facter::Utils.try_to_int('7string')).to be('7string')
      end

      it 'does not convert boolean true' do
        expect(Facter::Utils.try_to_int(true)).to be(true)
      end

      it 'does not convert boolean false' do
        expect(Facter::Utils.try_to_int(false)).to be(false)
      end

      it 'does not convert string float' do
        expect(Facter::Utils.try_to_int('7.10')).to be('7.10')
      end
    end
  end
end
