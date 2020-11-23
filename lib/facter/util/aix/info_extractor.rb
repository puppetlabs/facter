# frozen_string_literal: true

module Facter
  module Util
    module Aix
      module InfoExtractor
        MEGABYTES_EXPONENT = 1024**2
        GIGABYTES_EXPONENT = 1024**3

        def self.extract(content, regex)
          content = content.each_line.map do |line|
            next unless regex =~ line

            line.split(/:\s*|\s{2,}/)
          end

          content.flatten!.reject!(&:nil?)

          Hash[*content]
        end
      end
    end
  end
end
