# frozen_string_literal: true

module Facter
  module Utils
    # Sort nested hash.
    def self.sort_hash_by_key(hash, recursive = true, &block)
      hash.keys.sort(&block).each_with_object({}) do |key, seed|
        seed[key] = hash[key]
        seed[key] = sort_hash_by_key(seed[key], true, &block) if recursive && seed[key].is_a?(Hash)

        seed
      end
    end
  end
end
