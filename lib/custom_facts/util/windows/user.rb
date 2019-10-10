require_relative '../windows'
require 'ffi'

module LegacyFacter::Util::Windows::User
  extend FFI::Library

  def admin?
    elevated_supported = LegacyFacter::Util::Windows::Process.supports_elevated_security?

    # if Vista or later, check for unrestricted process token
    return LegacyFacter::Util::Windows::Process.elevated_security? if elevated_supported

    # otherwise 2003 or less
    check_token_membership
  end
  module_function :admin?


  # https://msdn.microsoft.com/en-us/library/windows/desktop/ee207397(v=vs.85).aspx
  SECURITY_MAX_SID_SIZE = 68

  def check_token_membership
    is_admin = false
    FFI::MemoryPointer.new(:byte, SECURITY_MAX_SID_SIZE) do |sid_pointer|
      FFI::MemoryPointer.new(:dword, 1) do |size_pointer|
        size_pointer.write_uint32(SECURITY_MAX_SID_SIZE)

        if CreateWellKnownSid(:WinBuiltinAdministratorsSid, FFI::Pointer::NULL, sid_pointer, size_pointer) == LegacyFacter::Util::Windows::FFI::WIN32_FALSE
          raise LegacyFacter::Util::Windows::Error.new("Failed to create administrators SID")
        end
      end

      if IsValidSid(sid_pointer) == LegacyFacter::Util::Windows::FFI::WIN32_FALSE
        raise RuntimeError,"Invalid SID"
      end

      FFI::MemoryPointer.new(:win32_bool, 1) do |ismember_pointer|
        if CheckTokenMembership(LegacyFacter::Util::Windows::FFI::NULL_HANDLE, sid_pointer, ismember_pointer) == LegacyFacter::Util::Windows::FFI::WIN32_FALSE
          raise LegacyFacter::Util::Windows::Error.new("Failed to check membership")
        end

        # Is administrators SID enabled in calling thread's access token?
        is_admin = LegacyFacter::Util::Windows::FFI.read_win32_bool(ismember_pointer)
      end
    end

    is_admin
  end
  module_function :check_token_membership

  private

  ffi_convention :stdcall

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa376389(v=vs.85).aspx
  # BOOL WINAPI CheckTokenMembership(
  #   _In_opt_  HANDLE TokenHandle,
  #   _In_      PSID SidToCheck,
  #   _Out_     PBOOL IsMember
  # );
  ffi_lib :advapi32
  attach_function :CheckTokenMembership,
                  [:handle, :pointer, :pbool], :win32_bool

  public

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa379650(v=vs.85).aspx
  WELL_KNOWN_SID_TYPE = enum(
      :WinNullSid                                   , 0,
      :WinWorldSid                                  , 1,
      :WinLocalSid                                  , 2,
      :WinCreatorOwnerSid                           , 3,
      :WinCreatorGroupSid                           , 4,
      :WinCreatorOwnerServerSid                     , 5,
      :WinCreatorGroupServerSid                     , 6,
      :WinNtAuthoritySid                            , 7,
      :WinDialupSid                                 , 8,
      :WinNetworkSid                                , 9,
      :WinBatchSid                                  , 10,
      :WinInteractiveSid                            , 11,
      :WinServiceSid                                , 12,
      :WinAnonymousSid                              , 13,
      :WinProxySid                                  , 14,
      :WinEnterpriseControllersSid                  , 15,
      :WinSelfSid                                   , 16,
      :WinAuthenticatedUserSid                      , 17,
      :WinRestrictedCodeSid                         , 18,
      :WinTerminalServerSid                         , 19,
      :WinRemoteLogonIdSid                          , 20,
      :WinLogonIdsSid                               , 21,
      :WinLocalSystemSid                            , 22,
      :WinLocalServiceSid                           , 23,
      :WinNetworkServiceSid                         , 24,
      :WinBuiltinDomainSid                          , 25,
      :WinBuiltinAdministratorsSid                  , 26,
      :WinBuiltinUsersSid                           , 27,
      :WinBuiltinGuestsSid                          , 28,
      :WinBuiltinPowerUsersSid                      , 29,
      :WinBuiltinAccountOperatorsSid                , 30,
      :WinBuiltinSystemOperatorsSid                 , 31,
      :WinBuiltinPrintOperatorsSid                  , 32,
      :WinBuiltinBackupOperatorsSid                 , 33,
      :WinBuiltinReplicatorSid                      , 34,
      :WinBuiltinPreWindows2000CompatibleAccessSid  , 35,
      :WinBuiltinRemoteDesktopUsersSid              , 36,
      :WinBuiltinNetworkConfigurationOperatorsSid   , 37,
      :WinAccountAdministratorSid                   , 38,
      :WinAccountGuestSid                           , 39,
      :WinAccountKrbtgtSid                          , 40,
      :WinAccountDomainAdminsSid                    , 41,
      :WinAccountDomainUsersSid                     , 42,
      :WinAccountDomainGuestsSid                    , 43,
      :WinAccountComputersSid                       , 44,
      :WinAccountControllersSid                     , 45,
      :WinAccountCertAdminsSid                      , 46,
      :WinAccountSchemaAdminsSid                    , 47,
      :WinAccountEnterpriseAdminsSid                , 48,
      :WinAccountPolicyAdminsSid                    , 49,
      :WinAccountRasAndIasServersSid                , 50,
      :WinNTLMAuthenticationSid                     , 51,
      :WinDigestAuthenticationSid                   , 52,
      :WinSChannelAuthenticationSid                 , 53,
      :WinThisOrganizationSid                       , 54,
      :WinOtherOrganizationSid                      , 55,
      :WinBuiltinIncomingForestTrustBuildersSid     , 56,
      :WinBuiltinPerfMonitoringUsersSid             , 57,
      :WinBuiltinPerfLoggingUsersSid                , 58,
      :WinBuiltinAuthorizationAccessSid             , 59,
      :WinBuiltinTerminalServerLicenseServersSid    , 60,
      :WinBuiltinDCOMUsersSid                       , 61,
      :WinBuiltinIUsersSid                          , 62,
      :WinIUserSid                                  , 63,
      :WinBuiltinCryptoOperatorsSid                 , 64,
      :WinUntrustedLabelSid                         , 65,
      :WinLowLabelSid                               , 66,
      :WinMediumLabelSid                            , 67,
      :WinHighLabelSid                              , 68,
      :WinSystemLabelSid                            , 69,
      :WinWriteRestrictedCodeSid                    , 70,
      :WinCreatorOwnerRightsSid                     , 71,
      :WinCacheablePrincipalsGroupSid               , 72,
      :WinNonCacheablePrincipalsGroupSid            , 73,
      :WinEnterpriseReadonlyControllersSid          , 74,
      :WinAccountReadonlyControllersSid             , 75,
      :WinBuiltinEventLogReadersGroup               , 76,
      :WinNewEnterpriseReadonlyControllersSid       , 77,
      :WinBuiltinCertSvcDComAccessGroup             , 78,
      :WinMediumPlusLabelSid                        , 79,
      :WinLocalLogonSid                             , 80,
      :WinConsoleLogonSid                           , 81,
      :WinThisOrganizationCertificateSid            , 82,
      :WinApplicationPackageAuthoritySid            , 83,
      :WinBuiltinAnyPackageSid                      , 84,
      :WinCapabilityInternetClientSid               , 85,
      :WinCapabilityInternetClientServerSid         , 86,
      :WinCapabilityPrivateNetworkClientServerSid   , 87,
      :WinCapabilityPicturesLibrarySid              , 88,
      :WinCapabilityVideosLibrarySid                , 89,
      :WinCapabilityMusicLibrarySid                 , 90,
      :WinCapabilityDocumentsLibrarySid             , 91,
      :WinCapabilitySharedUserCertificatesSid       , 92,
      :WinCapabilityEnterpriseAuthenticationSid     , 93,
      :WinCapabilityRemovableStorageSid             , 94
  )

  private

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa446585(v=vs.85).aspx
  # BOOL WINAPI CreateWellKnownSid(
  #   _In_       WELL_KNOWN_SID_TYPE WellKnownSidType,
  #   _In_opt_   PSID DomainSid,
  #   _Out_opt_  PSID pSid,
  #   _Inout_    DWORD *cbSid
  # );
  ffi_lib :advapi32
  attach_function :CreateWellKnownSid,
                  [WELL_KNOWN_SID_TYPE, :pointer, :pointer, :lpdword], :win32_bool

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa379151(v=vs.85).aspx
  # BOOL WINAPI IsValidSid(
  #   _In_  PSID pSid
  # );
  ffi_lib :advapi32
  attach_function :IsValidSid,
                  [:pointer], :win32_bool
end
