
class OsResolver2 < BaseResolver
  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize {
        result = check_if_cached(fact_name)
        if !result.nil?
          return result
        end

        output, _status = Open3.capture2('uname -a')
        version = output.match(/\d{1,2}\.\d{1,2}\.\d{1,2}/).to_s
        family = output.split(' ')[0]

        @@fact_list.merge!({name: family})
        @@fact_list.merge!({family: family})
        @@fact_list.merge!({release: version})

        return @@fact_list[fact_name]
        # return @@fact_list.dig(*fact_name.split('.').map(&:to_sym))
      }
    end

    def check_if_cached(fact_name)
      # @@facte_list.include?(fact_name)
      puts "!!!"
      @@fact_list[fact_name]
    end
  end
end
