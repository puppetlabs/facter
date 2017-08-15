require 'facter/util/windows'
require 'ffi'

module Facter::Util::Windows::Process
  extend FFI::Library

  def get_current_process
    # this pseudo-handle does not require closing per MSDN docs
    GetCurrentProcess()
  end
  module_function :get_current_process

  def open_process_token(handle, desired_access, &block)
    token_handle = nil
    begin
      FFI::MemoryPointer.new(:handle, 1) do |token_handle_ptr|
        result = OpenProcessToken(handle, desired_access, token_handle_ptr)
        if result == Facter::Util::Windows::FFI::WIN32_FALSE
          raise Facter::Util::Windows::Error.new(
              "OpenProcessToken(#{handle}, #{desired_access.to_s(8)}, #{token_handle_ptr})")
        end

        yield token_handle = Facter::Util::Windows::FFI.read_handle(token_handle_ptr)
      end

      token_handle
    ensure
      Facter::Util::Windows::FFI::WIN32.CloseHandle(token_handle) if token_handle
    end

    # token_handle has had CloseHandle called against it, so nothing to return
    nil
  end
  module_function :open_process_token

  def get_token_information(token_handle, token_information, &block)
    # to determine buffer size
    FFI::MemoryPointer.new(:dword, 1) do |return_length_ptr|
      result = GetTokenInformation(token_handle, token_information, nil, 0, return_length_ptr)
      return_length = Facter::Util::Windows::FFI.read_dword(return_length_ptr)

      if return_length <= 0
        raise Facter::Util::Windows::Error.new(
            "GetTokenInformation(#{token_handle}, #{token_information}, nil, 0, #{return_length_ptr})")
      end

      # re-call API with properly sized buffer for all results
      FFI::MemoryPointer.new(return_length) do |token_information_buf|
        result = GetTokenInformation(token_handle, token_information,
                                     token_information_buf, return_length, return_length_ptr)

        if result == Facter::Util::Windows::FFI::WIN32_FALSE
          raise Facter::Util::Windows::Error.new(
              "GetTokenInformation(#{token_handle}, #{token_information}, #{token_information_buf}, " +
                  "#{return_length}, #{return_length_ptr})")
        end

        yield token_information_buf
      end
    end

    # GetTokenInformation buffer has been cleaned up by this point, nothing to return
    nil
  end
  module_function :get_token_information

  def parse_token_information_as_token_elevation(token_information_buf)
    TOKEN_ELEVATION.new(token_information_buf)
  end
  module_function :parse_token_information_as_token_elevation

  TOKEN_QUERY = 0x0008
  # Returns whether or not the owner of the current process is running
  # with elevated security privileges.
  #
  # Only supported on Windows Vista or later.
  #
  def elevated_security?
    # default / pre-Vista
    elevated = false
    handle = nil

    begin
      handle = get_current_process
      open_process_token(handle, TOKEN_QUERY) do |token_handle|
        get_token_information(token_handle, :TokenElevation) do |token_info|
          token_elevation = parse_token_information_as_token_elevation(token_info)
          # TokenIsElevated member of the TOKEN_ELEVATION struct
          elevated = token_elevation[:TokenIsElevated] != 0
        end
      end

      elevated
    rescue Facter::Util::Windows::Error => e
      raise e if e.code != ERROR_NO_SUCH_PRIVILEGE
    ensure
      Facter::Util::Windows::FFI::WIN32.CloseHandle(handle) if handle
    end
  end
  module_function :elevated_security?

  STATUS_SUCCESS = 0

  def os_version(&block)
    FFI::MemoryPointer.new(OSVERSIONINFOEX.size) do |ver_ptr|
      ver = OSVERSIONINFOEX.new(ver_ptr)
      ver[:dwOSVersionInfoSize] = OSVERSIONINFOEX.size

      result = RtlGetVersion(ver_ptr)

      if result != STATUS_SUCCESS
        raise RuntimeError, 'Calling Windows RtlGetVersion failed'
      end

      yield ver
    end

    # ver_ptr has already had free called, so nothing to return
    nil
  end
  module_function :os_version

  def windows_major_version
    ver = 0

    self.os_version do |version|
      ver = version[:dwMajorVersion]
    end

    ver
  end
  module_function :windows_major_version

  def os_version_string
    ver = ''
    self.os_version do |version|
      ver = "#{version[:dwMajorVersion]}.#{version[:dwMinorVersion]}.#{version[:dwBuildNumber]}"
    end

    ver
  end
  module_function :os_version_string


  SM_SERVERR2 = 89

  def is_2003_r2?
    # Peculiar API from user32 - the docs for SM_SERVER2 indicate
    # The build number if the system is Windows Server 2003 R2; otherwise, 0.
    GetSystemMetrics(SM_SERVERR2) != 0
  end
  module_function :is_2003_r2?

  def supports_elevated_security?
    windows_major_version >= 6
  end
  module_function :supports_elevated_security?

  private

  ffi_convention :stdcall

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms683179(v=vs.85).aspx
  # HANDLE WINAPI GetCurrentProcess(void);
  ffi_lib :kernel32
  attach_function :GetCurrentProcess, [], :handle

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa379295(v=vs.85).aspx
  # BOOL WINAPI OpenProcessToken(
  #   _In_   HANDLE ProcessHandle,
  #   _In_   DWORD DesiredAccess,
  #   _Out_  PHANDLE TokenHandle
  # );
  ffi_lib :advapi32
  attach_function :OpenProcessToken,
                  [:handle, :dword, :phandle], :win32_bool

  public
  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa379626(v=vs.85).aspx
  TOKEN_INFORMATION_CLASS = enum(
      :TokenUser, 1,
      :TokenGroups,
      :TokenPrivileges,
      :TokenOwner,
      :TokenPrimaryGroup,
      :TokenDefaultDacl,
      :TokenSource,
      :TokenType,
      :TokenImpersonationLevel,
      :TokenStatistics,
      :TokenRestrictedSids,
      :TokenSessionId,
      :TokenGroupsAndPrivileges,
      :TokenSessionReference,
      :TokenSandBoxInert,
      :TokenAuditPolicy,
      :TokenOrigin,
      :TokenElevationType,
      :TokenLinkedToken,
      :TokenElevation,
      :TokenHasRestrictions,
      :TokenAccessInformation,
      :TokenVirtualizationAllowed,
      :TokenVirtualizationEnabled,
      :TokenIntegrityLevel,
      :TokenUIAccess,
      :TokenMandatoryPolicy,
      :TokenLogonSid,
      :TokenIsAppContainer,
      :TokenCapabilities,
      :TokenAppContainerSid,
      :TokenAppContainerNumber,
      :TokenUserClaimAttributes,
      :TokenDeviceClaimAttributes,
      :TokenRestrictedUserClaimAttributes,
      :TokenRestrictedDeviceClaimAttributes,
      :TokenDeviceGroups,
      :TokenRestrictedDeviceGroups,
      :TokenSecurityAttributes,
      :TokenIsRestricted,
      :MaxTokenInfoClass
  )

  # https://msdn.microsoft.com/en-us/library/windows/desktop/bb530717(v=vs.85).aspx
  # typedef struct _TOKEN_ELEVATION {
  #   DWORD TokenIsElevated;
  # } TOKEN_ELEVATION, *PTOKEN_ELEVATION;
  class TOKEN_ELEVATION < FFI::Struct
    layout :TokenIsElevated, :dword
  end

  private

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa446671(v=vs.85).aspx
  # BOOL WINAPI GetTokenInformation(
  #   _In_       HANDLE TokenHandle,
  #   _In_       TOKEN_INFORMATION_CLASS TokenInformationClass,
  #   _Out_opt_  LPVOID TokenInformation,
  #   _In_       DWORD TokenInformationLength,
  #   _Out_      PDWORD ReturnLength
  # );
  ffi_lib :advapi32
  attach_function :GetTokenInformation,
                  [:handle, TOKEN_INFORMATION_CLASS, :lpvoid, :dword, :pdword ], :win32_bool

  public

  # https://msdn.microsoft.com/en-us/library/windows/hardware/ff563620(v=vs.85).aspx
  # typedef struct _OSVERSIONINFOEXW {
  #   ULONG  dwOSVersionInfoSize;
  #   ULONG  dwMajorVersion;
  #   ULONG  dwMinorVersion;
  #   ULONG  dwBuildNumber;
  #   ULONG  dwPlatformId;
  #   WCHAR  szCSDVersion[128];
  #   USHORT wServicePackMajor;
  #   USHORT wServicePackMinor;
  #   USHORT wSuiteMask;
  #   UCHAR  wProductType;
  #   UCHAR  wReserved;
  # } RTL_OSVERSIONINFOEXW, *PRTL_OSVERSIONINFOEXW;
  class OSVERSIONINFOEX < FFI::Struct
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
      :wReserved, :uchar,
    )
  end

  private

  # NTSTATUS -> :int32 (defined in winerror.h / ntstatus.h)
  # https://msdn.microsoft.com/en-us/library/windows/hardware/ff561910(v=vs.85).aspx
  # NTSTATUS RtlGetVersion(
  #   _Out_ PRTL_OSVERSIONINFOW lpVersionInformation
  # );
  ffi_lib [FFI::CURRENT_PROCESS, :ntdll]
  attach_function :RtlGetVersion, [:pointer], :int32

  # C++ int is a signed 32-bit integer
  # int WINAPI GetSystemMetrics(
  #   _In_ int nIndex
  # );
  ffi_lib :user32
  attach_function :GetSystemMetrics, [:int32], :int32
end
