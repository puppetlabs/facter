class OsResolver < BaseResolver
  @@name
  @@family
  @@release

  class << self
    def resolve(search = [])
      search.flatten!(1)

      output, _status = Open3.capture2('uname -a')
      version = output.match(/\d{1,2}\.\d{1,2}\.\d{1,2}/).to_s
      family = output.split(' ')[0]
      # binding.pry
      result = {
        name: family,
        family: output.split(' ')[0],
        release: {
          major: version.split('.').first,
          minor: version.split('.')[1],
          full: version
        }
      }

      result = result.dig(*search.map(&:to_sym)) unless search.empty?
      result
    end
  end
end
