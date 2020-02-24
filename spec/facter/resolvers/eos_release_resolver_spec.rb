# frozen_string_literal: true

describe Facter::Resolvers::EosRelease do
  before do
    allow(Open3).to receive(:capture2)
      .with('cat /etc/Eos-release')
      .and_return('name version')
  end

  it 'returns name' do
    result = Facter::Resolvers::EosRelease.resolve(:name)

    expect(result).to eq('name')
  end

  it 'returns version' do
    result = Facter::Resolvers::EosRelease.resolve(:version)

    expect(result).to eq('version')
  end
end
