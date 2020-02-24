# frozen_string_literal: true

describe Facter::Resolvers::DebianVersion do
  before do
    allow(Open3).to receive(:capture2)
      .with('cat /etc/debian_version')
      .and_return("10.01\n")
  end

  it 'returns full' do
    result = Facter::Resolvers::DebianVersion.resolve(:full)

    expect(result).to eq('10.01')
  end

  it 'returns major' do
    result = Facter::Resolvers::DebianVersion.resolve(:major)

    expect(result).to eq('10')
  end

  it 'returns minor' do
    result = Facter::Resolvers::DebianVersion.resolve(:minor)

    expect(result).to eq('1')
  end
end
