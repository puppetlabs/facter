# This tests is intended to verify that passing the `--list-block-groups` flag
# will cause the names of blockable resolvers to be printed to stdout. It should not list
# any resolver name that is not blockable.
test_name "the `--list-block-groups` command line flag prints available block groups to stdout" do

  agents.each do |agent|
    step "the EC2 blockgroup should be listed" do
      on(agent, facter("--list-block-groups")) do
        assert_match(/EC2/, stdout, "Expected the EC2 group to be listed")
        assert_match(/ec2_metadata/, stdout, "Expected the EC2 group's facts to be listed")
        assert_no_match(/kernel/, stdout, "kernel facts should not be listed as blockable")
      end
    end
  end
end
