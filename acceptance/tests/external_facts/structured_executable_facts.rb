# This test is intended to demonstrate that executable external facts can return
# YAML or JSON data, in addition to plain key-value pairs. If the output cannot be
# parsed as YAML, it will fall back to key-value pair parsing, and only fail if
# this is also invalid.
test_name "executable external facts can return structured data" do

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  unix_fact_yaml = <<EOM
#!/bin/sh
echo "yaml_fact: [ 'one', 'two', 'three' ]"
EOM

  unix_fact_json = <<EOM
#!/bin/sh
echo "{ json_fact: { element: 1 } }"
EOM

  unix_fact_kv = <<EOM
#!/bin/sh
echo "kv_fact=one"
EOM

  unix_fact_bad = <<EOM
#!/bin/sh
echo "bad_fact : : not, json"
EOM

  win_fact_yaml = <<EOM
@echo off
echo yaml_fact: [ 'one', 'two', 'three' ]
EOM

  win_fact_json = <<EOM
@echo off
echo { json_fact: { element: 1 } }
EOM

  win_fact_kv = <<EOM
@echo off
echo kv_fact=one
EOM

  win_fact_bad = <<EOM
@echo off
echo bad_fact : : not, json
EOM

  yaml_structured_output = <<EOM
[
  "one",
  "two",
  "three"
]
EOM

  json_structured_output = <<EOM
{
  element => 1
}
EOM

  kv_output = 'one'

  agents.each do |agent|
    os_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
    factsd = get_factsd_dir(agent['platform'], os_version)
    ext = get_external_fact_script_extension(agent['platform'])

    if agent['platform'] =~ /windows/
      yaml_content = win_fact_yaml
      json_content = win_fact_json
      kv_content = win_fact_kv
      bad_fact_content = win_fact_bad
    else
      yaml_content = unix_fact_yaml
      json_content = unix_fact_json
      kv_content = unix_fact_kv
      bad_fact_content = unix_fact_bad
    end

    step "Agent #{agent}: setup default external facts directory (facts.d)" do
      on(agent, "mkdir -p '#{factsd}'")
    end

    teardown do
      on(agent, "rm -rf '#{factsd}'")
    end

    step "Agent #{agent}: create an executable yaml fact in default facts.d" do
      yaml_fact = File.join(factsd, "yaml_fact#{ext}")
      create_remote_file(agent, yaml_fact, yaml_content)
      on(agent, "chmod +x '#{yaml_fact}'")

      step "YAML output should produce a structured fact" do
        on(agent, facter("yaml_fact")) do
          assert_match(/#{yaml_structured_output}/, stdout, "Expected properly structured fact")
        end
      end
    end

    step "Agent #{agent}: create an executable json fact in default facts.d" do
      json_fact = File.join(factsd, "json_fact#{ext}")
      create_remote_file(agent, json_fact, json_content)
      on(agent, "chmod +x '#{json_fact}'")

      step "JSON output should produce a structured fact" do
        on(agent, facter("json_fact")) do
          assert_match(/#{json_structured_output}/, stdout, "Expected properly structured fact")
        end
      end
    end

    step "Agent #{agent}: create an executable key-value fact in default facts.d" do
      kv_fact = File.join(factsd, "kv_fact#{ext}")
      create_remote_file(agent, kv_fact, kv_content)
      on(agent, "chmod +x '#{kv_fact}'")

      step "output that is neither yaml nor json should not produce a structured fact" do
        on(agent, facter("kv_fact")) do
          assert_match(/#{kv_output}/, stdout, "Expected a simple key-value fact")
        end
      end
    end

    step "Agent #{agent}: create a malformed executable fact in default facts.d" do
      bad_fact = File.join(factsd, "bad_fact#{ext}")
      create_remote_file(agent, bad_fact, bad_fact_content)
      on(agent, "chmod +x '#{bad_fact}'")

      step "should error when output is not in a supported format" do
        on(agent, facter("bad_fact --debug")) do
          assert_match(/Could not parse executable fact/, stderr, "Expected parsing the malformed fact to fail")
        end
      end
    end
  end
end
