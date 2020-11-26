# frozen_string_literal: true

module Facter
  module Util
    module Facts
      class WindowsReleaseFinder
        class << self
          def find_release(input)
            version = input[:version]
            return unless version

            consumerrel = input[:consumerrel]
            description = input[:description]
            kernel_version = input[:kernel_version]

            if version =~ /10.0/
              check_version_10(consumerrel, kernel_version)
            else
              check_version_6(version, consumerrel) || check_version_5(version, consumerrel, description) || version
            end
          end

          private

          def check_version_10(consumerrel, kernel_version)
            build_number = kernel_version[/([^.]*)$/].to_i
            if consumerrel
              '10'
            elsif build_number >= 17_623
              '2019'
            else
              '2016'
            end
          end

          def check_version_6(version, consumerrel)
            hash = {}
            hash['6.3'] = consumerrel ? '8.1' : '2012 R2'
            hash['6.2'] = consumerrel ? '8' : '2012'
            hash['6.1'] = consumerrel ? '7' : '2008 R2'
            hash['6.0'] = consumerrel ? 'Vista' : '2008'
            hash[version]
          end

          def check_version_5(version, consumerrel, description)
            return unless version =~ /5.2/
            return 'XP' if consumerrel

            description == 'R2' ? '2003 R2' : '2003'
          end
        end
      end
    end
  end
end
