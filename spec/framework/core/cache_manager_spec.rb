# frozen_string_literal: true

describe Facter::CacheManager do
  it 'registers resolver subscription' do
    uname_resolver = double(Facter::Resolvers::Uname)
    Facter::CacheManager.subscribe(uname_resolver)
    expect(uname_resolver).to receive(:invalidate_cache)
    Facter::CacheManager.invalidate_all_caches
  end
end
