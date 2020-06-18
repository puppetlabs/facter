# This tests is intended to verify that passing the `--list-cache-groups` flag
# will cause the names of cacheable resolvers to be printed to stdout.
test_name "C99970: the `--list-cache-groups` command line flag prints available cache groups to stdout" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    external_dir = agent.tmpdir('external_dir')
    etc_factsd_dir = get_etc_factsd_dir(agent['platform'])
    filename = "test.yaml"
    etc_factsd_path = "#{etc_factsd_dir}/#{filename}"

    teardown do
      on(agent, "rm -rf '#{external_dir}' '#{etc_factsd_path}'")
    end

    step "the various cache groups should be listed" do
      on(agent, facter("--list-cache-groups")) do |facter_output|
        assert_match(/EC2/, facter_output.stdout, "EC2 group should be listed as cacheable")
        assert_match(/ec2_metadata/, facter_output.stdout, "EC2 group's facts should be listed")
        assert_match(/kernel/, facter_output.stdout, "kernel group should be listed as cacheable")
        assert_match(/kernelversion/, facter_output.stdout, "kernel group's facts should be listed as cacheable")
      end
    end

    step "the various external facts file should be visible as caching groups" do
      external_filename = "external_facts_filename"
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact_script = File.join(external_dir, "#{external_filename}#{ext}")
      create_remote_file(agent, external_fact_script, external_fact_content(agent['platform'], "a", "b"))
      on(agent, "chmod +x '#{external_fact_script}'")

      external_fact_script_txt = File.join(external_dir, "#{external_filename}.txt")
      create_remote_file(agent, external_fact_script_txt, '')

      external_fact_script_json = File.join(external_dir, "#{external_filename}.json")
      create_remote_file(agent, external_fact_script_json, '')

      external_fact_script_yaml = File.join(external_dir, "#{external_filename}.yaml")
      create_remote_file(agent, external_fact_script_yaml, '')

      on(agent, facter("--external-dir #{external_dir} --list-cache-groups")) do |facter_output|
        assert_match(/#{external_filename}#{ext}/, facter_output.stdout, "external facts script files should be listed as cacheable")
        assert_match(/#{external_filename}.txt/, facter_output.stdout, "external facts txt files should be listed as cacheable")
        assert_match(/#{external_filename}.json/, facter_output.stdout, "external facts json files should be listed as cacheable")
        assert_match(/#{external_filename}.yaml/, facter_output.stdout, "external facts yaml files should be listed as cacheable")
      end
      on(agent, "rm -rf '#{external_dir}'")
    end

    step "external facts groups should be listed only without --no-external-facts" do
      on(agent, "mkdir -p '#{etc_factsd_dir}'")
      create_remote_file(agent, etc_factsd_path, 'test_fact: test_value')
      on(agent, facter("--list-cache-groups")) do |facter_output|
        assert_match(/#{filename}/, facter_output.stdout, "external facts script files should be listed as cacheable")
      end
      on(agent, facter("--list-cache-groups --no-external-facts")) do |facter_output|
        assert_no_match(/#{filename}/, facter_output.stdout, "external facts script files should now be listed as cacheable when --no-external-facts is used")
      end
      on(agent, "rm -f '#{etc_factsd_path}'")
    end
  end
end
