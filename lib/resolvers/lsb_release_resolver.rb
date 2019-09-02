# frozen_string_literal: true

class LsbReleaseResolver < BaseResolver
  # "Distributor ID"
  # "Description"
  # "Release"
  # "Codename"

  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || read_lsb_release_file(fact_name)
      end
    end

    def read_lsb_release_file(fact_name)
      output, _status = Open3.capture2('lsb_release -a')
      release_info = output.delete("\t").split("\n").map { |e| e.split(':') }

      @@fact_list = Hash[*release_info.flatten]

      @@fact_list[fact_name]
    end
  end
end
