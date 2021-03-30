# frozen_string_literal: true

describe Facter::Framework::Lookup do
  describe '.split_key' do
    subject(:split_key) { Facter::Framework::Lookup.split_key(key) }

    context 'when key is nil' do
      let(:key) { nil }

      it { is_expected.to eql([nil]) }
    end

    context 'when key is empty string' do
      let(:key) { '' }

      it { is_expected.to eql(['']) }
    end

    context 'when key is simple string' do
      let(:key) { 'abc' }

      it { is_expected.to eql(['abc']) }
    end

    context 'when key is a number representation' do
      let(:key) { '123' }

      it { is_expected.to eql(['123']) }
    end

    context 'when key is simple string and quoted' do
      let(:key) { '"abc"' }

      it { is_expected.to eql(['abc']) }
    end

    context 'when key is special string and quoted' do
      let(:key) { '"a.b.c"' }

      it { is_expected.to eql(['a.b.c']) }
    end

    context 'when simple segment is quoted' do
      let(:key) { 'a."b"' }

      it { is_expected.to eql(%w[a b]) }
    end

    context 'when composed segment is quoted' do
      let(:key) { 'a."b.c"' }

      it { is_expected.to eql(['a', 'b.c']) }
    end

    context 'when composed segment is quoted and has digits' do
      let(:key) { 'a."1"' }

      it { is_expected.to eql(%w[a 1]) }
    end

    context 'when key contains unbalanced quotes' do
      let(:key) { 'a."b.c' }

      it { is_expected.to eql(['a."b.c']) }
    end

    context 'when key contains unbalanced single quote' do
      let(:key) { "a.b'.c" }

      it { is_expected.to eql(["a.b'.c"]) }
    end

    context 'when key is special and contains unbalanced quote' do
      let(:key) { 'a."b.c".d"' }

      it { is_expected.to eql(['a."b.c".d"']) }
    end

    context 'when key is special but not all parts are valid segments' do
      let(:key) { 'a.b."c.d""f.e"' }

      it { is_expected.to eql(['a.b."c.d""f.e"']) }
    end
  end

  describe '.join_keys' do
    subject(:join_keys) { Facter::Framework::Lookup.join_keys(segments) }

    context 'when segments are [nil]' do
      let(:segments) { [nil] }

      it { is_expected.to be(nil) }
    end

    context 'when segments are an empty string' do
      let(:segments) { [''] }

      it { is_expected.to eql('') }
    end

    context 'when segments are a simple string' do
      let(:segments) { ['abc'] }

      it { is_expected.to eql('abc') }
    end

    context 'when segments are a simple quoted string' do
      let(:segments) { ['"abc"'] }

      it { is_expected.to eql('"abc"') }
    end

    context 'when segments are a simple quoted number string' do
      let(:segments) { ['123'] }

      it { is_expected.to eql('123') }
    end

    context 'when segments are a special quoted string' do
      let(:segments) { ['a.b.c'] }

      it { is_expected.to eql('"a.b.c"') }
    end

    context 'when segments contain a quoted string' do
      let(:segments) { %w[a b] }

      it { is_expected.to eql('a.b') }
    end

    context 'when segments contain a composed string' do
      let(:segments) { ['a', 'b.c'] }

      it { is_expected.to eql('a."b.c"') }
    end

    context 'when segments contain a composed string with numbers' do
      let(:segments) { ['a', 12, 13] }

      it { is_expected.to eql('a.12.13') }
    end

    context 'when segments contain a unbalanced simple string' do
      let(:segments) { ['a."b.c'] }

      it { is_expected.to eql('a."b.c') }
    end

    context 'when segments contain a unbalanced special string' do
      let(:segments) { ['a."b.c".d"'] }

      it { is_expected.to eql('a."b.c".d"') }
    end

    context 'when segments contain a special string but not all parts are valid segments' do
      let(:segments) { ['a.b."c.d""f.e"'] }

      it { is_expected.to eql('a.b."c.d""f.e"') }
    end
  end
end
