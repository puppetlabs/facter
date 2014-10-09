require 'spec_helper'

describe "ruby platform" do
  it "should return the ruby platform" do
    expect(Facter.fact(:rubyplatform).value).to eq(RUBY_PLATFORM.to_s)
  end
end
