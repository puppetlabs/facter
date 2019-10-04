# frozen_string_literal: true

describe 'Ubuntu Path' do
  context '#call_the_resolver' do
    let(:value) do
      '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:' \
      '/bin:/usr/games:/usr/local/games'
    end

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: :path, value: value)

      allow(Facter::Resolvers::Path)
        .to receive(:resolve)
        .with(:path)
        .and_return(value)

      allow(Facter::ResolvedFact)
        .to receive(:new)
        .with('path', value)
        .and_return(expected_fact)

      fact = Facter::Ubuntu::Path.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
