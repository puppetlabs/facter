# This tests is intended to verify that passing the `--list-cache-groups` flag
# will cause the names of cacheable resolvers to be printed to stdout.
test_name "the `--list-cache-groups` command line flag prints available cache groups to stdout" do

  agents.each do |agent|
    step "the various cache groups should be listed" do
      on(agent, facter("--list-cache-groups")) do
         assert_match(/EC2/, stdout, "EC2 facts should be listed as cacheable")
         assert_match(/kernel/, stdout, "kernel facts should be listed as cacheable")
      end
    end
  end
end
