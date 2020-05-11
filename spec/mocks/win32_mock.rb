# frozen_string_literal: true

module Win32
  module Registry
    class HKEY_LOCAL_MACHINE
      def self.open(*); end

      def close; end

      def any?; end

      def each; end

      def [](*); end

      def keys; end
    end
  end
end
