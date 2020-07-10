require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::Normalization do
  subject(:normalization) { LegacyFacter::Util::Normalization }

  def utf16(str)
    if String.method_defined?(:encode) && defined?(::Encoding)
      str.encode(Encoding::UTF_16LE)
    else
      str
    end
  end

  def utf8(str)
    if String.method_defined?(:encode) && defined?(::Encoding)
      str.encode(Encoding::UTF_8)
    else
      str
    end
  end

  describe 'validating strings' do
    describe 'and string encoding is supported', if: String.instance_methods.include?(:encoding) do
      it 'accepts strings that are ASCII and match their encoding and converts them to UTF-8' do
        str = 'ASCII'.encode(Encoding::ASCII)
        normalized_str = normalization.normalize(str)
        expect(normalized_str.encoding).to eq(Encoding::UTF_8)
      end

      it 'accepts strings that are UTF-8 and match their encoding' do
        str = "let's make a ☃!".encode(Encoding::UTF_8)
        expect(normalization.normalize(str)).to eq(str)
      end

      it 'converts valid non UTF-8 strings to UTF-8' do
        str = "let's make a ☃!".encode(Encoding::UTF_16LE)
        enc = normalization.normalize(str).encoding
        expect(enc).to eq(Encoding::UTF_8)
      end

      it 'normalizes a frozen string returning a non-frozen string' do
        str = 'factvalue'.encode(Encoding::UTF_16LE).freeze

        normalized_str = normalization.normalize(str)
        expect(normalized_str).not_to be_frozen
      end

      it 'rejects strings that are not UTF-8 and do not match their claimed encoding' do
        invalid_shift_jis = "\xFF\x5C!".force_encoding(Encoding::SHIFT_JIS)
        expect do
          normalization.normalize(invalid_shift_jis)
        end.to raise_error(LegacyFacter::Util::Normalization::NormalizationError,
                           /String encoding Shift_JIS is not UTF-8 and could not be converted to UTF-8/)
      end

      it "rejects strings that claim to be UTF-8 encoded but aren't" do
        str = "\255ay!".force_encoding(Encoding::UTF_8)
        expect do
          normalization.normalize(str)
        end.to raise_error(LegacyFacter::Util::Normalization::NormalizationError,
                           /String.*doesn't match the reported encoding UTF-8/)
      end
    end

    describe 'and string encoding is not supported', unless: String.instance_methods.include?(:encoding) do
      it 'accepts strings that are UTF-8 and match their encoding' do
        str = "let's make a ☃!"
        expect(normalization.normalize(str)).to eq(str)
      end

      it 'rejects strings that are not UTF-8' do
        str = "let's make a \255\255\255!"
        expect do
          normalization.normalize(str)
        end.to raise_error(LegacyFacter::Util::Normalization::NormalizationError, /String .* is not valid UTF-8/)
      end
    end
  end

  describe 'normalizing arrays' do
    it 'normalizes each element in the array' do
      arr = [utf16('first'), utf16('second'), [utf16('third'), utf16('fourth')]]
      expected_arr = [utf8('first'), utf8('second'), [utf8('third'), utf8('fourth')]]

      expect(normalization.normalize_array(arr)).to eq(expected_arr)
    end
  end

  describe 'normalizing hashes' do
    it 'normalizes each element in the array' do
      hsh = { utf16('first') => utf16('second'), utf16('third') => [utf16('fourth'), utf16('fifth')] }
      expected_hsh = { utf8('first') => utf8('second'), utf8('third') => [utf8('fourth'), utf8('fifth')] }

      expect(normalization.normalize_hash(hsh)).to eq(expected_hsh)
    end
  end

  [1, 1.0, true, false, nil].each do |val|
    it "accepts #{val.inspect}:#{val.class}" do
      expect(normalization.normalize(val)).to eq(val)
    end
  end

  [Object.new, Set.new].each do |val|
    it "rejects #{val.inspect}:#{val.class}" do
      expect do
        normalization.normalize(val)
      end.to raise_error(LegacyFacter::Util::Normalization::NormalizationError, /Expected .*but was #{val.class}/)
    end
  end
end
