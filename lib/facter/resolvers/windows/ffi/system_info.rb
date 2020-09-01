# frozen_string_literal: true

class DummyStructName < FFI::Struct
  layout(
    :wProcessorArchitecture, :word,
    :wReserved, :word
  )
end

class DummyUnionName < FFI::Union
  layout(
    :dwOemId, :dword,
    :dummystructname, DummyStructName
  )
end

class SystemInfo < FFI::Struct
  layout(
    :dummyunionname, DummyUnionName,
    :dwPageSize, :dword,
    :lpMinimumApplicationAddress, :pointer,
    :lpMaximumApplicationAddress, :pointer,
    :dwActiveProcessorMask, :pdword,
    :dwNumberOfProcessors, :dword,
    :dwProcessorType, :dword,
    :dwAllocationGranularity, :dword,
    :wProcessorLevel, :word,
    :wProcessorRevision, :word
  )
end
