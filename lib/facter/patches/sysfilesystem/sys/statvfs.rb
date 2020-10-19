# frozen_string_literal: true

require 'sys/filesystem'

module Sys
  class Filesystem
    module Structs
      class Statvfs < FFI::Struct
        # We must remove the instance variable layout defined by sys-filesystem, because setting
        # it the second time will make FFI log a warning message.
        remove_instance_variable(:@layout) if @layout

        if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach/i
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint,
            :f_bfree, :uint,
            :f_bavail, :uint,
            :f_files, :uint,
            :f_ffree, :uint,
            :f_favail, :uint,
            :f_fsid, :ulong,
            :f_flag, :ulong,
            :f_namemax, :ulong
          )
        elsif RbConfig::CONFIG['host'] =~ /bsd/i
          layout(
            :f_bavail, :uint64,
            :f_bfree, :uint64,
            :f_blocks, :uint64,
            :f_favail, :uint64,
            :f_ffree, :uint64,
            :f_files, :uint64,
            :f_bsize, :ulong,
            :f_flag, :ulong,
            :f_frsize, :ulong,
            :f_fsid, :ulong,
            :f_namemax, :ulong
          )
        elsif RbConfig::CONFIG['host'] =~ /sunos|solaris/i
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint64_t,
            :f_bfree, :uint64_t,
            :f_bavail, :uint64_t,
            :f_files, :uint64_t,
            :f_ffree, :uint64_t,
            :f_favail, :uint64_t,
            :f_fsid, :ulong,
            :f_basetype, [:char, 16],
            :f_flag, :ulong,
            :f_namemax, :ulong,
            :f_fstr, [:char, 32],
            :f_filler, [:ulong, 16]
          )
        elsif RbConfig::CONFIG['host'] =~ /i686/i
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint,
            :f_bfree, :uint,
            :f_bavail, :uint,
            :f_files, :uint,
            :f_ffree, :uint,
            :f_favail, :uint,
            :f_fsid, :ulong,
            :f_flag, :ulong,
            :f_namemax, :ulong,
            :f_spare, [:int, 6]
          )
        else
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint64,
            :f_bfree, :uint64,
            :f_bavail, :uint64,
            :f_files, :uint64,
            :f_ffree, :uint64,
            :f_favail, :uint64,
            :f_fsid, :ulong,
            :f_flag, :ulong,
            :f_namemax, :ulong,
            :f_spare, [:int, 6]
          )
        end
      end
    end
  end
end
