module Facter
  module Util

    module Validation

      class ValidationError < StandardError; end

      VALID_TYPES = [Integer, Float, TrueClass, FalseClass, NilClass, String, Array, Hash]

      module_function

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

      # @!method validate_string(value)
      #
      # Validate that the given string is in a supported coding and matches that encoding.
      #
      # Valid encodings are UTF-8 and ASCII.
      #
      # On Ruby 1.8 the string is checked by stripping out all non UTF-8
      # characters and comparing the converted string to the original. If they
      # do not match then the string is considered invalid.
      #
      # On Ruby 1.9+, the string is checked by checking the string encoding
      # against accepted encodings and that the string content matches the
      # encoding.
      #
      # @api public
      # @raise [ValidationError] If the string used an unsupported encoding or did not match its encoding
      # @param value [String]
      # @return [void]

      if RUBY_VERSION =~ /^1\.8/
        require 'iconv'

        def validate_string(value)
          converted = Iconv.conv('UTF-8//IGNORE', 'UTF-8', value)
          if converted != value
            raise ValidationError, "String #{value.inspect} is not valid UTF-8"
          end
        end

      else
        SUPPORTED_ENCODINGS = [Encoding::US_ASCII, Encoding::UTF_8]

        def validate_string(value)

          unless SUPPORTED_ENCODINGS.include?(value.encoding)
            raise ValidationError, "String encoding #{value.encoding} is not a supported encoding (one of #{SUPPORTED_ENCODINGS.inspect})"
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
