# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Processors < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { query_pddv(fact_name) }
          end

          def query_pddv(fact_name)
            @fact_list[:models] = []
            @fact_list[:logical_count] = 0

            odmquery = Facter::ODMQuery.new
            odmquery.equals('class', 'processor')

            result = odmquery.execute

            return unless result

            proc_names = retrieve_from_array(result.scan(/uniquetype\s=\s.*/), 1)

            proc_names.each { |name| populate_from_cudv(name) }

            @fact_list[fact_name]
          end

          def populate_from_cudv(name)
            odmquery = Facter::ODMQuery.new
            odmquery.equals('PdDvLn', name)

            result = odmquery.execute

            return unless result

            names = retrieve_from_array(result.scan(/name\s=\s.*/), 1)

            names.each { |elem| query_cuat(elem) }
          end

          def query_cuat(name)
            odmquery = Facter::ODMQuery.new
            odmquery.equals('name', name)

            result = odmquery.execute

            return unless result

            type, frequency, smt_threads, smt_enabled = process(result)

            @fact_list[:speed] ||= frequency if frequency

            threads = smt_enabled ? smt_threads : 1

            @fact_list[:logical_count] += threads
            @fact_list[:models].concat([type] * threads)
          end

          def process(stdout)
            type = retrieve_from_array(stdout.scan(/attribute\s=\s"type"\n\s+value\s=\s.*/), 2).first
            frequency = retrieve_from_array(stdout.scan(/attribute\s=\s"frequency"\n\s+value\s=\s.*/), 2).first
            smt_threads = retrieve_from_array(stdout.scan(/attribute\s=\s"smt_threads"\n\s+value\s=\s.*/), 2).first
            smt_enabled = retrieve_from_array(stdout.scan(/attribute\s=\s"smt_enabled"\n\s+value\s=\s.*/), 2).first
            [type, frequency.to_i, smt_threads.to_i, smt_enabled]
          end

          def retrieve_from_array(array, pos)
            array.map { |elem| elem.split('=')[pos].strip.delete('"') }
          end
        end
      end
    end
  end
end
