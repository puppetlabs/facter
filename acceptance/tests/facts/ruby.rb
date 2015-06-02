test_name "The Ruby fact should resolve as expected in AIO"

#
# This test is intended to ensure that the the ruby fact resolves
# as expected in AIO across supported platforms.
#

skip_test "Ruby fact test is confined to AIO" if @options[:type] != 'aio'

step "Ensure the Ruby fact resolves as expected"

if agent['platform'] =~ /windows/
  ruby_platform = agent['ruby_arch'] == 'x64' ? 'x64-mingw32' : 'i386-mingw32'
else
  if agent['ruby_arch']
    ruby_platform = agent['ruby_arch'] == 'x64' ? 'x86_64-linux' : /i(4|6)86-linux/
  else
    ruby_platform = agent['platform'] =~ /64/ ? 'x86_64-linux' : /i(4|6)86-linux/
  end
end

ruby_version = '2.1.6'
expected_ruby = {
                  'ruby.platform' => ruby_platform,
                  'ruby.sitedir'  => /\/site_ruby/,
                  'ruby.version'  => ruby_version
                }

expected_ruby.each do |fact, value|
  assert_match(value, fact_on(agent, fact))
end
