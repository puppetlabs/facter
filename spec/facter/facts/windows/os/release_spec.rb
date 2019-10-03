# frozen_string_literal: true

describe 'Windows OsRelease' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release', value: { full: 'release', major: 'release' })
      allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:consumerrel).and_return('consumerrel')
      allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:description).and_return('description')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion).and_return('kernel_maj_version')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return('kernel_version')
      allow(Facter::WindowsReleaseFinder).to receive(:find_release).and_return('release')
      allow(Facter::ResolvedFact).to receive(:new).with('os.release', full: 'release', major: 'release')
                                                  .and_return(expected_fact)

      fact = Facter::Windows::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
