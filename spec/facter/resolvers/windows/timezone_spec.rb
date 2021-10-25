# frozen_string_literal: true

describe Facter::Resolvers::Windows::Timezone do
  before do
    Facter::Resolvers::Windows::Timezone.invalidate_cache
  end

  describe '#resolve timezone' do
    it 'resolves timezone with codepage from api' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('850')

      expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone).encoding.to_s).to eql('UTF-8')
    end

    it 'resolves timezone with codepage from registry' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('')
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry).and_return('850')

      expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone).encoding.to_s).to eql('UTF-8')
    end

    it 'resolves timezone with default codepage' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('')
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry).and_return('something_invalid')

      expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone).encoding).to eql(Time.now.zone.encoding)
    end

    it 'detects timezone' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage).and_return('850')

      timezone_result = Time.now.zone.force_encoding('CP850')
      expect(Facter::Resolvers::Windows::Timezone.resolve(:timezone)).to eql(timezone_result)
    end
  end

  describe '#codepage' do
    it 'gets codepage from api' do
      expect(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api)
      Facter::Resolvers::Windows::Timezone.resolve(:timezone)
    end

    it 'gets codepage from registry' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('')
      expect(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry)
      Facter::Resolvers::Windows::Timezone.resolve(:timezone)
    end

    it 'gets invalid codepage' do
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_api).and_return('')
      allow(Facter::Resolvers::Windows::Timezone).to receive(:codepage_from_registry).and_return('something_invalid')

      expect { Facter::Resolvers::Windows::Timezone.resolve(:timezone) }.not_to raise_error
    end
  end
end
