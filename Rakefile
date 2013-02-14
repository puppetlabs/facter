# Rakefile for facter

# We need access to the Puppet.version method
$LOAD_PATH.unshift(File.expand_path("lib"))
require 'facter/version'
require 'yaml'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

begin
  require 'rubygems'
  require 'rspec'
  require 'rspec/core/rake_task'
  require 'rcov'
rescue LoadError
end

require 'rake'

Dir['tasks/**/*.rake'].each { |t| load t }
Dir['ext/packaging/tasks/**/*'].sort.each { |t| load t }

build_defs_file = 'ext/build_defaults.yaml'
if File.exist?(build_defs_file)
  begin
    @build_defaults ||= YAML.load_file(build_defs_file)
  rescue Exception => e
    STDERR.puts "Unable to load yaml from #{build_defs_file}:"
    STDERR.puts e
  end
  @packaging_url  = @build_defaults['packaging_url']
  @packaging_repo = @build_defaults['packaging_repo']
  raise "Could not find packaging url in #{build_defs_file}" if @packaging_url.nil?
  raise "Could not find packaging repo in #{build_defs_file}" if @packaging_repo.nil?

  namespace :package do
    desc "Bootstrap packaging automation, e.g. clone into packaging repo"
    task :bootstrap do
      if File.exist?("ext/#{@packaging_repo}")
        puts "It looks like you already have ext/#{@packaging_repo}. If you don't like it, blow it away with package:implode."
      else
        cd 'ext' do
          %x{git clone #{@packaging_url}}
        end
      end
    end
    desc "Remove all cloned packaging automation"
    task :implode do
      rm_rf "ext/#{@packaging_repo}"
    end
  end
end

task :default do
  sh %{rake -T}
end

if defined?(RSpec::Core::RakeTask)
  desc "Run all specs"
  RSpec::Core::RakeTask.new do |t|
    t.pattern ='spec/{unit,integration}/**/*_spec.rb'
    t.fail_on_error = true
  end

  RSpec::Core::RakeTask.new('spec:rcov') do |t|
    t.pattern ='spec/{unit,integration}/**/*_spec.rb'
    t.fail_on_error = true
    if defined?(Rcov)
      t.rcov = true
      t.rcov_opts = ['--exclude', 'spec/*,test/*,results/*,/usr/lib/*,/usr/local/lib/*,gems/*']
    end
  end
end

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
