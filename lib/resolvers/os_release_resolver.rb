# frozen_string_literal: true

module Facter
  module Resolvers
    class OsRelease < BaseResolver
      # :pretty_name
      # :name
      # :version_id
      # :version
      # :id
      # :id_like
      # :ansi_color
      # :home_url
      # :support_url
      # :bug_report_url

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_os_release_file(fact_name) }
        end

        def read_os_release_file(fact_name)
          unless File.readable?('/etc/os-release')
            @fact_list[:name] = nil
            return
          end

          output = File.read('/etc/os-release')
          pairs = []

          output.each_line do |line|
            pairs << line.strip.delete('"').split('=', 2)
          end

          fill_fact_list(pairs)
          process_name

          @fact_list[fact_name]
        end

        def fill_fact_list(pairs)
          result = Hash[*pairs.flatten]
          result.each { |k, v| @fact_list[k.downcase.to_sym] = v }

          @fact_list[:identifier] = @fact_list[:id]
        end

        def process_name
          return unless @fact_list[:name]

          @fact_list[:name] = if @fact_list[:name].downcase.start_with?('red')
                                @fact_list[:name].split(' ')[0..1].join
                              else
                                @fact_list[:name].split(' ')[0].strip
                              end
        end
      end
    end
  end
end
