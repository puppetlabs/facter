Facter.add(:rubyversion) do
    setcode { RUBY_VERSION.to_s }
end
