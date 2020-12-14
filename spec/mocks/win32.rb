# frozen_string_literal: true

module Win32
  class Registry
    def keys; end

    def close; end

    class HKEY_LOCAL_MACHINE
      def self.open(*); end

      def close; end

      def any?; end

      def each; end

      def [](*); end

      def keys; end

      def read(*); end
    end
  end
end
