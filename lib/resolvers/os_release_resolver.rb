# frozen_string_literal: true

class OsReleaseResolver < BaseResolver
  # "PRETTY_NAME",
  # "NAME",
  # "VERSION_ID",
  # "VERSION",
  # "ID",
  # "ANSI_COLOR",
  # "HOME_URL",
  # "SUPPORT_URL",
  # "BUG_REPORT_URL"

  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || read_os_release_file(fact_name)
      end
    end

    def read_os_release_file(fact_name)
      output, _status = Open3.capture2('cat /etc/os-release')
      pairs = []

      output.each_line do |line|
        pairs << line.strip.delete('"').split('=', 2)
      end

      @@fact_list = Hash[*pairs.flatten]

      @@fact_list[:slug] = @@fact_list['ID'].downcase

      @@fact_list[fact_name]
    end
  end
end
