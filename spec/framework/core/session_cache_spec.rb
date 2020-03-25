# frozen_string_literal: true

describe Facter::SessionCache do
  it 'registers resolver subscription' do
    uname_resolver = double(Facter::Resolvers::Uname)
    Facter::SessionCache.subscribe(uname_resolver)
    expect(uname_resolver).to receive(:invalidate_cache)
    Facter::SessionCache.invalidate_all_caches
  end
end
