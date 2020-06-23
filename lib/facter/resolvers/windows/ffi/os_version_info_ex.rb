# frozen_string_literal: true

class OsVersionInfoEx < FFI::Struct
  layout(
    :dwOSVersionInfoSize, :win32_ulong,
    :dwMajorVersion, :win32_ulong,
    :dwMinorVersion, :win32_ulong,
    :dwBuildNumber, :win32_ulong,
    :dwPlatformId, :win32_ulong,
    :szCSDVersion, [:wchar, 128],
    :wServicePackMajor, :ushort,
    :wServicePackMinor, :ushort,
    :wSuiteMask, :ushort,
    :wProductType, :uchar,
    :wReserved, :uchar
  )
end
