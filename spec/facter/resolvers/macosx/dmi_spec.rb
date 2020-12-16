# frozen_string_literal: true

describe Facter::Resolvers::Macosx::DmiBios do
  subject(:dmi_resolver) { Facter::Resolvers::Macosx::DmiBios }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:macosx_model) { 'MacBookPro11,4' }

  before do
    dmi_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('sysctl -n hw.model', logger: log_spy)
      .and_return(macosx_model)
  end

  context 'when it detects model' do
    it 'detects model' do
      expect(Facter::Resolvers::Macosx::DmiBios.resolve(:macosx_model)).to eql(macosx_model)
    end
  end
end
