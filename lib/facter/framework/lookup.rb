# frozen_string_literal: true

module Facter
  module Framework
    module Lookup
      class << self
        SPECIAL = /['"\.]/.freeze
        SEGMENTS_REGEX = /(\s*"[^"]+"\s*|\s*'[^']+'\s*|[^'".]+)/.freeze

        # Split key into segments. A segment may be a quoted string (both single and double quotes can
        # be used) and the segment separator is the '.' character. Whitespace will be trimmed off on
        # both sides of each segment. Whitespace within quotes are not trimmed.
        #
        # If the key cannot be parsed, the inital key is returned
        #
        # Example:
        # "a.b.c"     => ["a", "b", "c"]
        # "a.\"b.c\"" => ["a", "b.c"]
        # "a.\"b.c"   => ["a.\"b.c"]
        # "\"a.b.c\"" => ["a.b.c"]
        #
        # @param key [String] the String to split
        # @return [Array<String>] the Array of segments
        def split_key(key)
          return [key] unless key =~ SPECIAL

          segments = key.split(SEGMENTS_REGEX)

          # Only happens if the original key was an empty string
          return [key] if segments.empty?

          return [key] unless segments.shift == ''

          count = segments.size
          return [key] unless count.positive?

          segments.keep_if { |seg| seg != '.' }
          return [key] unless segments.size * 2 == count + 1

          generate_segments!(segments)
        end

        # Joins an array of Strings using the '.' character. Wraps segments with qoutes
        # Example:
        # ["a", "b", "c"] => "a.b.c"
        # ["a", "b.c"]    => "a.\"b.c\""
        # ["a.\"b.c"]     => "a.\"b.c"
        # ["a.b.c"]       => "\"a.b.c\""
        #
        # @param arr [Array<String>] the Array of Strings
        # @return [String] the joined String
        def join_keys(arr)
          return arr[0] if arr.size == 1 && arr[0] !~ /^((\w+\.\w+)+(\.\w+)?)$/

          arr.map do |el|
            if el.instance_of?(String) && el.include?('.')
              "\"#{el}\""
            else
              el
            end
          end.join('.')
        end

        private

        def generate_segments!(arr)
          arr.map! do |segment|
            segment.strip!
            if segment.start_with?('"', "'")
              segment[1..-2]
            elsif segment =~ /^(:?[+-]?[0-9]+)$/
              segment.to_i
            else
              segment
            end
          end
        end
      end
    end
  end
end
