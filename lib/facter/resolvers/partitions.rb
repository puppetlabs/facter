# frozen_string_literal: true

module Facter
  module Resolvers
    class Partitions < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      BLOCK_PATH = '/sys/block'
      BLOCK_SIZE = 512

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_partitions(fact_name) }
        end

        def read_partitions(fact_name)
          @fact_list[:partitions] = {}
          return {} unless File.readable?(BLOCK_PATH)

          block_devices = Dir.entries(BLOCK_PATH).reject { |dir| dir =~ /^\.+/ }
          block_devices.each do |block_device|
            block_path = "#{BLOCK_PATH}/#{block_device}"
            if File.directory?("#{block_path}/device")
              extract_from_device(block_path)
            elsif File.directory?("#{block_path}/dm")
              extract_from_dm(block_path)
            elsif File.directory?("#{block_path}/loop")
              extract_from_loop(block_path)
            end
          end
          @fact_list[fact_name]
        end

        def extract_from_device(block_path)
          subdirs = browse_subdirectories(block_path)
          subdirs.each do |subdir|
            name = "/dev/#{subdir.split('/').last}"
            populate_partitions(name, subdir)
          end
        end

        def extract_from_dm(block_path)
          map_name = Util::FileHelper.safe_read("#{block_path}/dm/name").chomp
          if map_name.empty?
            populate_partitions("/dev#{block_path}", block_path)
          else
            populate_partitions("/dev/mapper/#{map_name}", block_path)
          end
        end

        def extract_from_loop(block_path)
          backing_file = Util::FileHelper.safe_read("#{block_path}/loop/backing_file").chomp
          if backing_file.empty?
            populate_partitions("/dev#{block_path}", block_path)
          else
            populate_partitions("/dev#{block_path}", block_path, backing_file)
          end
        end

        def populate_partitions(partition_name, block_path, backing_file = nil)
          @fact_list[:partitions][partition_name] = {}
          size_bytes = Util::FileHelper.safe_read("#{block_path}/size", '0')
                                       .chomp.to_i * BLOCK_SIZE
          info_hash = { size_bytes: size_bytes,
                        size: Facter::FactsUtils::UnitConverter.bytes_to_human_readable(size_bytes),
                        backing_file: backing_file }
          info_hash.merge!(populate_from_syscalls(partition_name))
          @fact_list[:partitions][partition_name] = info_hash.reject { |_key, value| value.nil? }
        end

        def populate_from_syscalls(partition_name)
          part_info = populate_from_blkid(partition_name)

          return pupulate_from_lsblk(partition_name) if part_info.empty?

          part_info
        end

        def populate_from_blkid(partition_name)
          return {} unless blkid_command?

          @blkid_content ||= execute_and_extract_blkid_info
          return {} unless @blkid_content[partition_name]

          filesys = @blkid_content[partition_name]['TYPE']
          uuid = @blkid_content[partition_name]['UUID']
          label = @blkid_content[partition_name]['LABEL']
          part_uuid = @blkid_content[partition_name]['PARTUUID']
          part_label = @blkid_content[partition_name]['PARTLABEL']
          { filesystem: filesys, uuid: uuid, label: label, partuuid: part_uuid, partlabel: part_label }
        end

        def blkid_command?
          return @blkid_exists unless @blkid_exists.nil?

          output = Facter::Core::Execution.execute('which blkid', logger: log)

          @blkid_exists = !output.empty?
        end

        def pupulate_from_lsblk(partition_name)
          return {} unless lsblk_command?

          @lsblk_content ||= Facter::Core::Execution.execute('lsblk -fp', logger: log)

          part_info = @lsblk_content.match(/#{partition_name}.*/).to_s.split(' ')
          return {} if part_info.empty?

          result = { filesystem: part_info[1] }

          if part_info.count.eql?(5)
            result[:label] = part_info[2]
            result[:uuid] = part_info[3]
          else
            result[:uuid] = part_info[2]
          end

          result
        end

        def lsblk_command?
          return @lsblk_exists unless @lsblk_exists.nil?

          output = Facter::Core::Execution.execute('which lsblk', logger: log)

          @lsblk_exists = !output.empty?
        end

        def execute_and_extract_blkid_info
          stdout = Facter::Core::Execution.execute('blkid', logger: log)
          output_hash = Hash[*stdout.split(/^([^:]+):/)[1..-1]]
          output_hash.each do |key, value|
            output_hash[key] = Hash[*value.delete('"').chomp.rstrip.split(/ ([^= ]+)=/)[1..-1]]
          end
        end

        def browse_subdirectories(path)
          dirs = Dir[File.join(path, '**', '*')].select { |p| File.directory? p }
          dirs.select { |subdir| subdir.split('/').last.include?(path.split('/').last) }.reject(&:nil?)
        end
      end
    end
  end
end
