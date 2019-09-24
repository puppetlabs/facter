# frozen_string_literal: true

describe 'ResolverManager' do
  it 'registers resolver subscription' do
    uname_resolver = double(Facter::Resolvers::Uname)
    Facter::ResolverManager.subscribe(uname_resolver)
    expect(uname_resolver).to receive(:invalidate_cache)
    Facter::ResolverManager.invalidate_all_caches
  end
end
