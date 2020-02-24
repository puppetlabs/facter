# frozen_string_literal: true

describe Facter::Resolvers::OsLevel do
  before do
    allow(Open3).to receive(:capture2)
      .with('/usr/bin/oslevel -s 2>/dev/null')
      .and_return('build')
  end

  it 'returns build' do
    result = Facter::Resolvers::OsLevel.resolve(:build)

    expect(result).to eq('build')
  end
end
