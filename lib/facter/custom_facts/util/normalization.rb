# frozen_string_literal: true

module LegacyFacter
  module Util
    module Normalization
      class NormalizationError < StandardError; end

      # load Date and Time classes
      require 'time'

      VALID_TYPES = [Integer, Float, TrueClass, FalseClass, NilClass, Symbol, String, Array, Hash, Date, Time].freeze

      module_function

      # Recursively normalize the given data structure
      #
      # @api public
      # @raise [NormalizationError] If the data structure contained an invalid element.
      # @return [void]
      def normalize(fact_name, value)
        case value
        when Integer, Float, TrueClass, FalseClass, NilClass, Symbol
          value
        when Date, Time
          value.iso8601
        when String
          normalize_string(fact_name, value)
        when Array
          normalize_array(fact_name, value)
        when Hash
          normalize_hash(fact_name, value)
        else
          raise NormalizationError, "Expected #{value} to be one of #{VALID_TYPES.inspect}, but was #{value.class}"
        end
      end

      # @!method normalize_string(value)
      #
      # Attempt to normalize and validate the given string.
      #
      # The string is validated by checking that the string encoding
      # is UTF-8 and that the string content matches the encoding. If the string
      # is not an expected encoding then it is converted to UTF-8.
      #
      # @api public
      # @raise [NormalizationError] If the string used an unsupported encoding or did not match its encoding
      # @param value [String]
      # @return [void]

      def normalize_string(fact_name, value)
        if value.encoding == Encoding::ASCII_8BIT
          value_copy_encoding = value.dup.force_encoding(Encoding::UTF_8)
          raise NormalizationError, "custom fact \"#{fact_name}\" with value: #{value_copy_encoding} contains binary data and could not be force encoded to UTF-8" unless value_copy_encoding.valid_encoding?

          log.debug("custom fact \"#{fact_name}\" with value: #{value} contained binary data and was force encoded to UTF-8 and now has the value: #{value_copy_encoding}")
          value = value_copy_encoding

        else
          value = value.encode(Encoding::UTF_8)
        end

        unless value.valid_encoding?
          raise NormalizationError, "String #{value.inspect} doesn't match the reported encoding #{value.encoding}"
        end

        if value.codepoints.include?(0)
          raise NormalizationError, "String #{value.inspect} contains a null byte reference; unsupported for all facts."
        end

        value
      rescue EncodingError
        raise NormalizationError, "String encoding #{value.encoding} is not UTF-8 and could not be converted to UTF-8"
      end

      # Validate all elements of the array.
      #
      # @api public
      # @raise [NormalizationError] If one of the elements failed validation
      # @param value [Array]
      # @return [void]
      def normalize_array(fact_name, value)
        value.collect do |elem|
          normalize(fact_name, elem)
        end
      end

      # Validate all keys and values of the hash.
      #
      # @api public
      # @raise [NormalizationError] If one of the keys or values failed normalization
      # @param value [Hash]
      # @return [void]
      def normalize_hash(fact_name, value)
        Hash[value.collect { |k, v| [normalize(fact_name, k), normalize(fact_name, v)] }]
      end

      def log
        Facter::Log.new(self)
      end
    end
  end
end
