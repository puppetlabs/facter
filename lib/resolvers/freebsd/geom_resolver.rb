# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class Geom < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            require_relative 'ffi/ffi_helper'
            require 'rexml/document'

            read_disks
            read_partitions

            @fact_list[fact_name]
          end

          def read_disks
            @fact_list[:disks] = {}

            each_geom_class_provider('DISK') do |provider|
              name = provider.get_text('./name').value

              @fact_list[:disks][name] = %i[read_model read_serial_number read_size].map do |x|
                send(x, provider)
              end.inject(:merge)
            end
          end

          def read_partitions
            @fact_list[:partitions] = {}

            each_geom_class_provider('PART') do |provider|
              name = provider.get_text('./name').value

              @fact_list[:partitions][name] = %i[read_partlabel read_partuuid read_size].map do |x|
                send(x, provider)
              end.inject(:merge)
            end
          end

          def each_geom_class_provider(geom_class_name, &block)
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
            @geom_topology ||= REXML::Document.new(geom_confxml)
          end

          def geom_confxml
            Facter::Freebsd::FfiHelper.sysctl_by_name(:string, 'kern.geom.confxml')
          end
        end
      end
    end
  end
end
