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

    def self.deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end

    def self.split_user_query(user_query)
      queries = user_query.split('.')
      queries.map! { |query| query =~ /^[0-9]+$/ ? query.to_i : query }
    end

    def self.deep_stringify_keys(object)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[key.to_s] = deep_stringify_keys(value)
        end
      when Array
        object.map { |e| deep_stringify_keys(e) }
      else
        object
      end
    end
  end
end
