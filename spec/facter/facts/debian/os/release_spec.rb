# frozen_string_literal: true

describe 'Ubuntu OsRelease' do
  context '#call_the_resolver' do
    let(:value) { { 'release' => { 'full' => '10.9', 'major' => '10', 'minor' => '9' } } }
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release', value: value)
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:release).and_return('10.9')
      allow(Facter::ResolvedFact).to receive(:new).with('os.release', value).and_return(expected_fact)

      fact = Facter::Debian::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
