# frozen_string_literal: true

describe Facter::SessionCache do
  let(:uname_resolver) { Facter::Resolvers::Uname.new }

  it 'registers resolver subscription' do
    expect(uname_resolver.class).to receive(:invalidate_cache)

    Facter::SessionCache.subscribe(uname_resolver.class)
    Facter::SessionCache.invalidate_all_caches
  end
end
