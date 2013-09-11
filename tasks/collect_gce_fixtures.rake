namespace :collect do
  desc "Scrape GCE Metadata into fixtures, scrubbing sensitive data"
  task :gce_metadata do
    collect_gce_metadata
  end

  ##
  # collect_gce_metadata walks the Google's GCE Metadata API and records each
  # request and response instance as a serialized YAML string.  This method is
  # intended to be used by Rake tasks Puppet users invoke to collect data for
  # development and troubleshooting purposes.
  def collect_gce_metadata(key='/', date=Time.now.strftime("%F"), dir="spec/fixtures/unit/util/gce")
    require 'timeout'
    require 'net/http'
    require 'uri'

    # Local variables
    file_prefix = "gce_metadata#{key.gsub(/[^a-zA-Z0-9]+/, '_')}".gsub(/_+$/, '').gsub(/\d{12}/,'111111111111')
    response = nil

    Dir.chdir(dir) do
      uri = URI("http://metadata/computeMetadata/v1beta1#{key}")
      Timeout::timeout(4) do
        Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Get.new(uri.request_uri)
          response = scrub_gce(key.split("/")[-1], http.request(request))

          write_gce_fixture(request, "#{file_prefix}_request.yaml")
          write_gce_fixture(response, "#{file_prefix}_response.yaml")
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
  # write_gce_fixture dumps an internal Ruby object to a file intended to be
  # used as a fixture for spec testing.
  #
  def write_gce_fixture(obj, filename, quiet=false)
    File.open(filename, "w+") do |fd|
      s = YAML.dump(obj)
      fd.write(s.gsub(/\d{12}/,'111111111111'))
    end
    puts "Wrote: #{filename}" unless quiet
  end

  ##
  # scrub_gce scrubs sensitive data from HTTP response before writing fixtures
  # to disk metadata will be scrubbed with the following changes:
  #  - project_number becomes '111111111111'
  #  - project_id becomes 'development_project'
  #  - sshKeys are trimmed
  #  - auth token is masked out
  #
  # @return [Net::HTTPResponse] Sanitized GCE response in YAML format
  def scrub_gce(key, resp)
    case key
    when "sshKeys"
      resp.body = "googler:ssh-rsa AAA...ej googler@facter-dev\n"
      resp["content-length"] = "44"
    when "project-id"
      resp.body = "development_project"
      resp["content-length"] = "19"
    when "token"
      resp.body = '{"access_token":"ya29.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","expires_in":1234,"token_type":"Bearer"}'
    end
    resp
  end
end
