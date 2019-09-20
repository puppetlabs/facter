# frozen_string_literal: true

describe 'OsLevel' do
  before do
    allow(Open3).to receive(:capture2)
      .with('oslevel -s')
      .and_return('build')
  end

  it 'returns build' do
    result = Facter::Resolvers::OsLevel.resolve(:build)

    expect(result).to eq('build')
  end
end
