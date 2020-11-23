# frozen_string_literal: true

module Facter
  module Resolvers
    class Partitions < BaseResolver
      init_resolver

      BLOCK_PATH = '/sys/block'
      BLOCK_SIZE = 512

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_partitions(fact_name) }
        end

        def read_partitions(fact_name)
          return unless File.readable?(BLOCK_PATH)

          block_devices = Dir.entries(BLOCK_PATH).reject { |dir| dir =~ /^\.+/ }
          @fact_list[:partitions] = {} unless block_devices.empty?
          blkid_and_lsblk = {}

          block_devices.each do |block_device|
            block_path = "#{BLOCK_PATH}/#{block_device}"
            if File.directory?("#{block_path}/device")
              extract_from_device(block_path, blkid_and_lsblk)
            elsif File.directory?("#{block_path}/dm")
              extract_from_dm(block_path, block_device, blkid_and_lsblk)
            elsif File.directory?("#{block_path}/loop")
              extract_from_loop(block_path, block_device, blkid_and_lsblk)
            end
          end

          @fact_list[fact_name]
        end

        def extract_from_device(block_path, blkid_and_lsblk)
          subdirs = browse_subdirectories(block_path)
          subdirs.each do |subdir|
            name = "/dev/#{subdir.split('/').last}"
            populate_partitions(name, subdir, blkid_and_lsblk)
          end
        end

        def extract_from_dm(block_path, block_device, blkid_and_lsblk)
          map_name = Facter::Util::FileHelper.safe_read("#{block_path}/dm/name").chomp
          if map_name.empty?
            populate_partitions("/dev/#{block_device}", block_path, blkid_and_lsblk)
          else
            populate_partitions("/dev/mapper/#{map_name}", block_path, blkid_and_lsblk)
          end
        end

        def extract_from_loop(block_path, block_device, blkid_and_lsblk)
          backing_file = Facter::Util::FileHelper.safe_read("#{block_path}/loop/backing_file").chomp
          if backing_file.empty?
            populate_partitions("/dev/#{block_device}", block_path, blkid_and_lsblk)
          else
            populate_partitions("/dev/#{block_device}", block_path, blkid_and_lsblk, backing_file)
          end
        end

        def populate_partitions(partition_name, block_path, blkid_and_lsblk, backing_file = nil)
          size_bytes = Facter::Util::FileHelper.safe_read("#{block_path}/size", '0')
                                               .chomp.to_i * BLOCK_SIZE
          info_hash = { size_bytes: size_bytes,
                        size: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(size_bytes),
                        backing_file: backing_file }
          info_hash.merge!(populate_from_syscalls(partition_name, blkid_and_lsblk))
          @fact_list[:partitions][partition_name] = info_hash.reject { |_key, value| value.nil? }
        end

        def populate_from_syscalls(partition_name, blkid_and_lsblk)
          part_info = populate_from_blkid(partition_name, blkid_and_lsblk)

          return populate_from_lsblk(partition_name, blkid_and_lsblk) if part_info.empty?

          part_info
        end

        def browse_subdirectories(path)
          dirs = Dir[File.join(path, '**', '*')].select { |p| File.directory? p }
          dirs.select { |subdir| subdir.split('/').last.include?(path.split('/').last) }.reject(&:nil?)
        end

        def populate_from_blkid(partition_name, blkid_and_lsblk)
          return {} unless available?('blkid', blkid_and_lsblk)

          blkid_and_lsblk[:blkid] ||= execute_and_extract_blkid_info

          partition_data = blkid_and_lsblk[:blkid][partition_name]
          return {} unless partition_data

          filesys = partition_data['TYPE']
          uuid = partition_data['UUID']
          label = partition_data['LABEL']
          part_uuid = partition_data['PARTUUID']
          part_label = partition_data['PARTLABEL']

          { filesystem: filesys, uuid: uuid, label: label, partuuid: part_uuid, partlabel: part_label }
        end

        def available?(command, blkid_and_lsblk)
          command_exists_key = command == 'blkid' ? :blkid_exists : :lsblk_exists

          return blkid_and_lsblk[command_exists_key] unless blkid_and_lsblk[command_exists_key].nil?

          output = Facter::Core::Execution.execute("which #{command}", logger: log)

          blkid_and_lsblk[:command_exists_key] = !output.empty?
        end

        def execute_and_extract_blkid_info
          stdout = Facter::Core::Execution.execute('blkid', logger: log)
          output_hash = Hash[*stdout.split(/^([^:]+):/)[1..-1]]
          output_hash.each do |key, value|
            output_hash[key] = Hash[*value.delete('"').chomp.rstrip.split(/ ([^= ]+)=/)[1..-1]]
          end
        end

        def populate_from_lsblk(partition_name, blkid_and_lsblk)
          return {} unless available?('lsblk', blkid_and_lsblk)

          blkid_and_lsblk[:lsblk] ||= Facter::Core::Execution.execute('lsblk -fp', logger: log)

          part_info = blkid_and_lsblk[:lsblk].match(/#{partition_name}.*/).to_s.split(' ')
          return {} if part_info.empty?

          parse_part_info(part_info)
        end

        def parse_part_info(part_info)
          result = { filesystem: part_info[1] }

          if part_info.count.eql?(5)
            result[:label] = part_info[2]
            result[:uuid] = part_info[3]
          else
            result[:uuid] = part_info[2]
          end

          result
        end
      end
    end
  end
end
