namespace :collect do
  desc "Scrape EC2 Metadata into fixtures"
  task :ec2_metadata do
    collect_metadata
  end

  ##
  # collect_metadata walks the Amazon AWS EC2 Metadata API and records each
  # request and response instance as a serialized YAML string.  This method is
  # intended to be used by Rake tasks Puppet users invoke to collect data for
  # development and troubleshooting purposes.
  def collect_metadata(key='/', date=Time.now.strftime("%F"), dir="spec/fixtures/unit/util/ec2")
    require 'timeout'
    require 'net/http'
    require 'uri'

    # Local variables
    file_prefix = "ec2_meta_data#{key.gsub(/[^a-zA-Z0-9]+/, '_')}".gsub(/_+$/, '')
    response = nil

    Dir.chdir(dir) do
      uri = URI("http://169.254.169.254/latest/meta-data#{key}")
      Timeout::timeout(4) do
        Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(request)

          write_fixture(request, "#{file_prefix}_request.yaml")
          write_fixture(response, "#{file_prefix}_response.yaml")
        end
      end
    end

    ##
    # if the current key is a directory, decend into all of the files.  If the
    # current key is not, we've already written it out and we're done.
    if key.end_with? "/"
      response.read_body.lines.each do |line|
        collect_metadata("#{key}#{line.chomp}", date, dir)
      end
    end
  end

  ##
  # write_fixture dumps an internal Ruby object to a file intended to be used
  # as a fixture for spec testing.
  #
  # @return [String] Serialized string model representation of obj
  def write_fixture(obj, filename, quiet=false)
    File.open(filename, "w+") do |fd|
      fd.write(YAML.dump(request))
    end
    puts "Wrote: #{dir}/#{request_file}" unless quiet
  end
end
