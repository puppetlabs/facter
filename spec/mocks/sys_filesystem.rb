# frozen_string_literal: true

module Sys
  class Filesystem
    def self.mounts; end

    class Mount
      def self.mount_point; end

      def self.mount_type; end

      def self.options; end

      def self.mount_time; end

      def self.name; end

      def self.dump_frequency; end

      def self.pass_number; end
    end

    class Stat
      def self.path; end

      def self.base_type; end

      def self.fragment_size; end

      def self.block_size; end

      def self.blocks; end

      def self.blocks_available; end

      def self.blocks_free; end

      def self.bytes_total; end

      def self.bytes_available; end

      def self.bytes_free; end

      def self.bytes_used; end
    end
  end
end
