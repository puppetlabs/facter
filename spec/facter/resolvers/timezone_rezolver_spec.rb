# frozen_string_literal: true

describe Facter::Resolvers::Timezone do
  describe '#resolve timezone' do
    it 'detects timezone' do
      expect(Facter::Resolvers::Timezone.resolve(:timezone)).to eql(Time.now.localtime.strftime('%Z'))
    end
  end
end
