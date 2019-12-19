# frozen_string_literal: true

describe 'Augeas' do
  before do
    allow(Open3).to receive(:capture2)
      .with('augparse --version 2>&1')
      .and_return('augparse 1.12.0 <http://augeas.net/>')
  end

  it 'returns build' do
    result = Facter::Resolvers::Augeas.resolve(:augeas_version)

    expect(result).to eq('1.12.0')
  end
end
