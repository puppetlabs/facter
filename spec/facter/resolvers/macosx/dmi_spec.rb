# frozen_string_literal: true

describe Facter::Resolvers::Macosx::DmiBios do
  subject(:dmi_resolver) { Facter::Resolvers::Macosx::DmiBios }

  let(:macosx_model) { 'MacBookPro11,4' }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('sysctl -n hw.model', logger: an_instance_of(Facter::Log))
      .and_return(macosx_model)
  end

  context 'when it detects model' do
    it 'detects model' do
      expect(Facter::Resolvers::Macosx::DmiBios.resolve(:macosx_model)).to eql(macosx_model)
    end
  end
end
