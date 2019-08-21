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

        return result unless result.nil?

        output, _status = Open3.capture2('cat /etc/os-release')
        release_info = output.delete('\"').split("\n").map { |e| e.split('=') }

        @@fact_list = Hash[*release_info.flatten]
				@@fact_list[:slug] = @@fact_list['ID'].downcase

        @@fact_list[fact_name]
      end
    end
  end
end
