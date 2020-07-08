# frozen_string_literal: true

module Facter
  module Resolvers
    class Xen < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      XEN_PATH = '/proc/xen/capabilities'

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { detect_xen(fact_name) }
        end

        def detect_xen(fact_name)
          @fact_list[:vm] = detect_xen_type
          @fact_list[:privileged] = privileged?(@fact_list[:vm])

          @fact_list[fact_name]
        end

        def detect_xen_type
          xen_type = 'xen0' if File.exist?('/dev/xen/evtchn')
          xen_type = 'xenu' if !xen_type && (File.exist?('/proc/xen') || File.exist?('/dev/xvda1'))

          xen_type
        end

        def privileged?(xen_type)
          content = Util::FileHelper.safe_read(XEN_PATH, nil)
          content&.strip == 'control_d' || xen_type == 'xen0'
        end
      end
    end
  end
end
