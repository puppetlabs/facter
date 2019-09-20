# frozen_string_literal: true

module Facter
  module Resolvers
    class WinOsReleaseResolver < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || build_fact_list
          end
        end

        private

        def read_from_ole
          win = Win32Ole.new
          op_sys = win.return_first('SELECT ProductType,OtherTypeDescription FROM Win32_OperatingSystem')
          unless op_sys
            @log.debug 'WMI query returned no results for Win32_OperatingSystem'\
                       'with values ProductType and OtherTypeDescription.'
            return
          end
          consumerrel = op_sys.ProductType == '1'
          description = op_sys.OtherTypeDescription
          version = KernelResolver.resolve(:kernelmajorversion)
          return unless version

          if version =~ /10.0/
            check_version_10(consumerrel)
          else
            check_version_6(version, consumerrel) || check_version_5(version, consumerrel, description) || version
          end
        end

        def check_version_10(consumerrel)
          kernel_version = KernelResolver.resolve(:kernelversion)
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
          hash = { '6.3' => consumerrel ? '8.1' : '2012 R2', '6.2' => consumerrel ? '8' : '2012',
                   '6.1' => consumerrel ? '7' : '2008 R2', '6.0' => consumerrel ? 'Vista' : '2008' }
          hash[version]
        end

        def check_version_5(version, consumerrel, description)
          return unless version =~ /5.2/
          return 'XP' if consumerrel

          description == 'R2' ? '2003 R2' : '2003'
        end

        def build_fact_list
          release = read_from_ole
          return unless release

          @fact_list[:full] = release
        end
      end
    end
  end
end
