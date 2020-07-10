# frozen_string_literal: true

describe Facter::SessionCache do
  let(:uname_resolver) { spy(Facter::Resolvers::Uname) }

  it 'registers resolver subscription' do
    Facter::SessionCache.subscribe(uname_resolver)
    Facter::SessionCache.invalidate_all_caches

    expect(uname_resolver).to have_received(:invalidate_cache)
  end
end
