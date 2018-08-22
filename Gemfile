source ENV['GEM_SOURCE'] || 'https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/'

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

gem 'packaging', *location_for(ENV['PACKAGING_LOCATION'] || '~> 0.99')
