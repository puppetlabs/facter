# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class Geom < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        DISKS_ATTRIBUTES = %i[read_model read_serial_number read_size].freeze
        PARTITIONS_ATTRIBUTES = %i[read_partlabel read_partuuid read_size].freeze

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            require_relative 'ffi/ffi_helper'
            require 'rexml/document'

            topology = geom_topology
            read_data('DISK', topology, DISKS_ATTRIBUTES)
            read_data('PART', topology, PARTITIONS_ATTRIBUTES)

            @fact_list[fact_name]
          end

          def read_data(fact_name, geom_topology, data_to_read)
            fact_list_key = fact_name == 'DISK' ? :disks : :partitions
            @fact_list[fact_list_key] = {}

            each_geom_class_provider(fact_name, geom_topology) do |provider|
              name = provider.get_text('./name').value

              @fact_list[fact_list_key][name] = data_to_read.map do |x|
                send(x, provider)
              end.inject(:merge)
            end
          end

          def each_geom_class_provider(geom_class_name, geom_topology, &block)
            REXML::XPath.each(geom_topology, "/mesh/class[name/text() = '#{geom_class_name}']/geom/provider", &block)
          end

          def read_size(provider)
            res = {}
            return res unless (mediasize = provider.get_text('mediasize'))

            mediasize = Integer(mediasize.value)

            res[:size_bytes] = mediasize
            res[:size] = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(mediasize)
            res
          end

          def read_model(provider)
            res = {}
            return res unless (model = provider.get_text('./config/descr'))

            res[:model] = model.value
            res
          end

          def read_partlabel(provider)
            res = {}
            return res unless (rawuuid = provider.get_text('./config/label'))

            res[:partlabel] = rawuuid.value
            res
          end

          def read_partuuid(provider)
            res = {}
            return res unless (rawuuid = provider.get_text('./config/rawuuid'))

            res[:partuuid] = rawuuid.value
            res
          end

          def read_serial_number(provider)
            res = {}
            return res unless (serial_number = provider.get_text('./config/ident'))

            res[:serial_number] = serial_number.value
            res
          end

          def geom_topology
            REXML::Document.new(geom_confxml)
          end

          def geom_confxml
            Facter::Freebsd::FfiHelper.sysctl_by_name(:string, 'kern.geom.confxml')
          end
        end
      end
    end
  end
end
