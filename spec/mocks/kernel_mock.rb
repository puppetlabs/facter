# frozen_string_literal: true

LIBS_TO_SKIP = %W[win32ole ffi win32/registry #{ROOT_DIR}/ext/cpuid.so].freeze
module Kernel
  alias old_require require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end
