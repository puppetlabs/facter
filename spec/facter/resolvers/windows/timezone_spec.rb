# frozen_string_literal: true

describe Facter::Resolvers::Windows::Timezone do
  describe '#resolve timezone' do
    it 'detects timezone' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage).and_return('850')

      timezone_result = Time.now.zone.force_encoding('CP850')
      expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone)).to eql(timezone_result)
    end

    describe '#codepage' do
      before do
        Facter::Resolvers::Windows::Timezone.invalidate_cache
      end

      it 'gets codepage from api' do
        allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('850')
        allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry).and_return('unknown')

        expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone).encoding.to_s).to eql('CP850')
      end

      it 'gets codepage from registry' do
        allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('')
        allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry).and_return('850')

        expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone).encoding.to_s).to eql('CP850')
      end

      it 'gets no codepage' do
        allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('invalid')
        allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry).and_return('also_invalid')

        expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone).encoding).to eql(Time.now.zone.encoding)
      end
    end
  end
end
