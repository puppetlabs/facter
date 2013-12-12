module Facter
  module Util

    module Validation

      class ValidationError < StandardError; end

      VALID_TYPES = [Integer, Float, TrueClass, FalseClass, NilClass, String, Array, Hash]

      extend self

      # Recursively validate the given data structure
      #
      # @api public
      # @raise [ValidationError] If the data structure contained an invalid element.
      # @return [void]
      def validate(value)
        case value
        when Integer, Float, TrueClass, FalseClass, NilClass
          true
        when String
          validate_string(value)
        when Array
          validate_array(value)
        when Hash
          validate_hash(value)
        else
          raise ValidationError, "Expected #{value} to be one of #{VALID_TYPES.inspect}, but was #{value.class}"
        end
      end

      # Validate that the given string is in a supported coding and matches that encoding.
      #
      # Valid encodings are UTF-8 and ASCII.
      #
      # @api public
      # @raise [ValidationError] If the string used an unsupported encoding or did not match its encoding
      # @param value [String]
      # @return [void]
      def validate_string(value)
        if value.respond_to? :encoding and value.respond_to? :valid_encoding?
          supported_encodings = [Encoding::US_ASCII, Encoding::UTF_8]

          unless supported_encodings.include?(value.encoding)
            raise ValidationError, "String encoding #{value.encoding} is not a supported encoding (one of #{supported_encodings.inspect})"
          end

          unless value.valid_encoding?
            raise ValidationError, "String #{value.inspect} doesn't match the reported encoding #{value.encoding}"
          end
        end
      end

      # Validate all elements of the array.
      #
      # @api public
      # @raise [ValidationError] If one of the elements failed validation
      # @param value [Array]
      # @return [void]
      def validate_array(value)
        value.each do |elem|
          validate(elem)
        end
      end

      # Validate all keys and values of the hash.
      #
      # @api public
      # @raise [ValidationError] If one of the keys or values failed validation
      # @param value [Hash]
      # @return [void]
      def validate_hash(value)
        value.each_pair do |k, v|
          validate(k)
          validate(v)
        end
      end
    end
  end
end
