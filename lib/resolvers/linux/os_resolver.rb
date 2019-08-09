class OsResolver < BaseResolver
  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]

        return result unless result.nil?

        output, _status = Open3.capture2('uname -a')
        version = output.match(/\d{1,2}\.\d{1,2}\.\d{1,2}/).to_s
        family = output.split(' ')[0]

        @@fact_list[:name] = family
        @@fact_list[:family] = family
        @@fact_list[:release] = version

        return @@fact_list[fact_name]
      end
    end
  end
end
