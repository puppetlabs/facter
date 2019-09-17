# frozen_string_literal: true

class PerformanceInformation < FFI::Struct
  layout(
    :cb, :dword,
    :CommitTotal, :size_t,
    :CommitLimit, :size_t,
    :CommitPeak, :size_t,
    :PhysicalTotal, :size_t,
    :PhysicalAvailable, :size_t,
    :SystemCache, :size_t,
    :KernelTotal, :size_t,
    :KernelPaged, :size_t,
    :KernelNonpaged, :size_t,
    :PageSize, :size_t,
    :HandleCount, :dword,
    :ProcessCount, :dword,
    :ThreadCount, :dword
  )
end
