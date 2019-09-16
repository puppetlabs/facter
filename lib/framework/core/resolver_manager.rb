# frozen_string_literal: true

module Facter
  class ResolverManager
    def self.invalidate_all_caches
      resolver_class_names = discover_all_resolver_class_names

      resolver_class_names.each do |resolver_class_name|
        resolver_class = Class.const_get("Facter::Resolvers::#{resolver_class_name}")

        resolver_class.invalidate_cache if resolver_class < Resolvers::BaseResolver
      end
    end

    def self.discover_all_resolver_class_names
      constants_in_resolver = Module.const_get('Facter::Resolvers')

      # select only classes
      constants_in_resolver.constants.select { |constant| constants_in_resolver.const_get(constant).is_a? Class }
    end
  end
end
