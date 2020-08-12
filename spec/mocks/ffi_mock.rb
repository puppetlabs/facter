# frozen_string_literal: true

module FFI
  ERROR_MORE_DATA = 234
  CURRENT_PROCESS = 0
  MAX_PATH = 32_767

  @error_number = nil
  def self.typedef(arg1, arg2); end

  def self.errno
    @error_number
  end

  def self.define_errno(arg)
    @error_number = arg
  end

  def self.type_size(arg); end

  module Library
    LIBC = 'libc'

    def ffi_convention(arg); end

    def ffi_lib(*); end

    def attach_function(*); end

    def enum(*); end

    def GetAdaptersAddresses(*); end

    def getkerninfo(*); end

    def getloadavg(*); end

    def sysctl(*); end

    def sysctlbyname(*); end

    def WSAAddressToStringW(*); end

    def GetNativeSystemInfo(*); end

    def GetUserNameExW(*); end

    def IsUserAnAdmin(*); end

    def RtlGetVersion(*); end

    def GetPerformanceInfo(*); end

    def IsWow64Process(*); end

    def GetCurrentProcess(*); end
  end

  class Pointer
    NULL = nil

    def write_uint32(); end

    def read_uint32(); end
  end

  class MemoryPointer
    def initialize(*); end

    def read_array_of_double(*); end

    def to_ptr; end

    def [](*); end
  end

  class Struct
    def self.layout(*); end

    def self.size; end

    def initialize(*); end

    def [](*); end

    def []=(*); end
  end

  class Union
    def self.layout(*); end

    def self.size; end
  end
end
