module Facter
  module Util
    class DefinedFact 
      module TypeValidator
        def self.valid?(type, value)
          type = type.to_s
          begin
            require "facter/util/defined_fact/type_validator/#{type.downcase}"
            klass = const_get "#{type.capitalize}"
            klass.valid?(value)
          rescue LoadError, NameError
            true
          end
        end
      end
    end
  end
end