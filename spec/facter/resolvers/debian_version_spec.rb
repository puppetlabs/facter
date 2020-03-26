# frozen_string_literal: true

describe Facter::Resolvers::DebianVersion do
  before do
    allow(File).to receive(:readable?).with('/etc/debian_version').and_return(true)
    allow(File).to receive(:read).with('/etc/debian_version').and_return("10.01\n")
  end

  it 'returns version' do
    result = Facter::Resolvers::DebianVersion.resolve(:version)

    expect(result).to eq('10.01')
  end
end
