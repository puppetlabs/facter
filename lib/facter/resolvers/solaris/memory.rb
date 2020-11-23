# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Memory < BaseResolver
        init_resolver
        BLOCKSIZE = 512
        # :system
        # :swap

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { calculate_memory(fact_name) }
          end

          def calculate_memory(fact_name)
            @fact_list = { system: sys, swap: swap }

            @fact_list[fact_name]
          end

          def sys
            sys = {}
            output = Facter::Core::Execution.execute('/usr/bin/kstat -m unix -n system_pages', logger: log).strip
            total, free = parse_sys_output(output)

            return unless total || free

            sys[:total_bytes] = total
            sys[:available_bytes] = free
            sys[:used_bytes] = total - free
            sys[:capacity] = Facter::Util::Resolvers::FilesystemHelper.compute_capacity(total - free, total)

            sys
          end

          def swap
            swap_hash = {}
            output = Facter::Core::Execution.execute('/usr/sbin/swap -l', logger: log).strip
            total, free = parse_swap_output(output)

            swap_hash[:total_bytes] = total
            swap_hash[:available_bytes] = free
            swap_hash[:used_bytes] = total - free
            swap_hash[:capacity] = Facter::Util::Resolvers::FilesystemHelper.compute_capacity(total - free, total)

            swap_hash if total != 0
          end

          def parse_sys_output(output)
            kstats = output.scan(/(physmem|pagesfree)\s+(\d+)/)
            kstats = kstats.to_h
            return unless kstats['physmem'] || kstats['pagesfree']
            return unless pagesize != 0

            total = kstats['physmem'].to_i * pagesize
            free = kstats['pagesfree'].to_i * pagesize

            [total, free]
          end

          def parse_swap_output(output)
            total = 0
            free = 0

            output.each_line do |line|
              swap_sizes = line.match(/(\d+)\s+(\d+)$/)
              next if swap_sizes.nil?

              total += swap_sizes[1].to_i
              free += swap_sizes[2].to_i
            end
            total *= BLOCKSIZE
            free *= BLOCKSIZE

            [total, free]
          end

          def pagesize
            unless @fact_list[:pagesize]
              @fact_list[:pagesize] = Facter::Core::Execution.execute('pagesize', logger: log).strip.to_i
              log.debug("Pagesize: #{@fact_list[:pagesize]}")
            end
            @fact_list[:pagesize]
          end
        end
      end
    end
  end
end
