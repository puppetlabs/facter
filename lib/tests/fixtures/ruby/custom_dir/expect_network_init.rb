require 'net/http'
Facter.add('sometest') do
  setcode do
    uri = URI("http://www.puppet.com")
    if (Net::HTTP.get_response(uri))
      'Yay'
    else
      'Nay'
    end
  end
end