# This tests is intended to verify that passing the `--list-cache-groups` flag
# will cause the names of cacheable resolvers to be printed to stdout.
test_name "C99970: the `--list-cache-groups` command line flag prints available cache groups to stdout" do
  tag 'risk:medium'

  agents.each do |agent|
    step "the various cache groups should be listed" do
      on(agent, facter("--list-cache-groups")) do |facter_output|
        assert_match(/EC2/, facter_output.stdout, "EC2 group should be listed as cacheable")
        assert_match(/ec2_metadata/, facter_output.stdout, "EC2 group's facts should be listed")
        assert_match(/kernel/, facter_output.stdout, "kernel group should be listed as cacheable")
        assert_match(/kernelversion/, facter_output.stdout, "kernel group's facts should be listed as cacheable")
      end
    end
  end
end
