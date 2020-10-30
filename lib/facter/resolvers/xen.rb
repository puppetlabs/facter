# frozen_string_literal: true

module Facter
  module Resolvers
    class Xen < BaseResolver
      init_resolver

      XEN_PATH = '/proc/xen/capabilities'
      XEN_TOOLSTACK = '/usr/lib/xen-common/bin/xen-toolstack'
      XEN_COMMANDS = ['/usr/sbin/xl', '/usr/sbin/xm'].freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { detect_xen(fact_name) }
        end

        def detect_xen(fact_name)
          @fact_list[:vm] = detect_xen_type
          @fact_list[:privileged] = privileged?(@fact_list[:vm])
          @fact_list[:domains] = detect_domains

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

        def detect_domains
          domains = []
          xen_command = find_command
          return unless xen_command

          output = Facter::Core::Execution.execute("#{xen_command} list", logger: log)
          return if output.empty?

          output.each_line do |line|
            next if line =~ /Domain-0|Name/

            domain = line.match(/^([^\s]*)\s/)
            domain = domain&.captures&.first
            domains << domain if domain
          end

          domains
        end

        def find_command
          return XEN_TOOLSTACK if File.exist?(XEN_TOOLSTACK)

          XEN_COMMANDS.each { |command| return command if File.exist?(command) }
        end
      end
    end
  end
end
