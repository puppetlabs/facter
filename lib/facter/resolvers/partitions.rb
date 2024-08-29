# frozen_string_literal: true

module Facter
  module Resolvers
    class Partitions < BaseResolver
      init_resolver

      BLOCK_PATH = '/sys/block'
      BLOCK_SIZE = 512

      class << self
        private

        def post_resolve(fact_name, _options)
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
          @fact_list[:partitions][partition_name] = info_hash.compact
        end

        def populate_from_syscalls(partition_name, blkid_and_lsblk)
          # Prefer lsblk over blkid since lsblk does not require root, returns more information, and is recommended by blkid
          part_info = populate_from_lsblk(partition_name, blkid_and_lsblk)

          return populate_from_blkid(partition_name, blkid_and_lsblk) if part_info.empty?

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

          blkid_and_lsblk[command_exists_key] = !Facter::Core::Execution.which(command).nil?
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

          lsblk_version_raw = Facter::Core::Execution.execute('lsblk --version 2>&1', logger: log)
          # Return if the version of lsblk is too old (< 2.22) to support the --version flag
          lsblk_version_raw.match?(/ \d\.\d+/) ? lsblk_version = lsblk_version_raw.match(/ \d\.\d+/)[0].to_f : (return {})

          # The -p/--paths option was added in lsblk 2.23, return early and fall back to blkid with earlier versions
          return {} if lsblk_version < 2.23

          blkid_and_lsblk[:lsblk] ||= execute_and_extract_lsblk_info(lsblk_version)

          partition_data = blkid_and_lsblk[:lsblk][partition_name]
          return {} unless partition_data

          filesys = partition_data['FSTYPE']
          uuid = partition_data['UUID']
          label = partition_data['LABEL']
          part_uuid = partition_data['PARTUUID']
          part_label = partition_data['PARTLABEL']
          part_type = partition_data['PARTTYPE']

          result = { filesystem: filesys, uuid: uuid, label: label, partuuid: part_uuid, partlabel: part_label }
          result[:parttype] = part_type if part_type

          result
        end

        def execute_and_extract_lsblk_info(lsblk_version)
          # lsblk 2.25 added support for GPT partition type GUIDs
          stdout = if lsblk_version >= 2.25
                     Facter::Core::Execution.execute('lsblk -p -P -o NAME,FSTYPE,UUID,LABEL,PARTUUID,PARTLABEL,PARTTYPE', logger: log)
                   else
                     Facter::Core::Execution.execute('lsblk -p -P -o NAME,FSTYPE,LABEL,UUID,PARTUUID,PARTLABEL', logger: log)
                   end

          output_hash = Hash[*stdout.split(/^(NAME=\S+)/)[1..-1]]
          output_hash.transform_keys! { |key| key.delete('NAME=')[1..-2] }
          output_hash.each do |key, value|
            output_hash[key] = Hash[*value.chomp.rstrip.split(/ ([^= ]+)=/)[1..-1].each { |x| x.delete!('"') }]
          end
          output_hash.each_value { |value_hash| value_hash.delete_if { |_k, v| v.empty? } }
          output_hash.delete_if { |_k, v| v.empty? }
        end
      end
    end
  end
end
