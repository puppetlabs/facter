# This tests is intended to verify that passing the `--list-block-groups` flag
# will cause the names of blockable resolvers to be printed to stdout. It should not list
# any resolver name that is not blockable.
test_name "C99969: the `--list-block-groups` command line flag prints available block groups to stdout" do
  tag 'risk:medium'

  agents.each do |agent|
    step "the EC2 blockgroup should be listed" do
      on(agent, facter("--list-block-groups")) do |facter_output|
        assert_match(/EC2/, facter_output.stdout, "Expected the EC2 group to be listed")
        assert_match(/ec2_metadata/, facter_output.stdout, "Expected the EC2 group's facts to be listed")
      end
    end
  end
end
