test_name "C96148: verify dmi facts" do
  tag 'risk:med'

  confine :except, :platform => 'aix' # no dmi support
  confine :except, :platform => 'huawei' # no dmi support
  confine :except, :platform => 'osx' # no dmi support
  confine :except, :platform => 'sparc' # no dmi support
  confine :except, :platform => 'ppc64' # no dmi support on linux on powerpc
  confine :except, :platform => 'aarch64' # no dmi support on linux on ARM64

  require 'json'
  require 'facter/acceptance/base_fact_utils'
  extend Facter::Acceptance::BaseFactUtils

  agents.each do |agent|
    expected_facts = {
        'dmi.manufacturer' => /\w+/,
        'dmi.product.name' => /\w+/,
    }
    unless agent['platform'] =~ /windows/
      expected_facts.merge!({'dmi.bios.release_date' => /\d+\/\d+\/\d+/,
                             'dmi.bios.vendor'       => /\w+/,
                             'dmi.bios.version'      => /\d+/,
                             'dmi.chassis.type'      => /\w+/,
                             'dmi.product.uuid'      => /[-0-9A-Fa-f]+/,
                            })
    end
    unless agent['platform'] =~ /windows|cisco/
      expected_facts.merge!({'dmi.chassis.asset_tag' => /\w+/})
    end
    unless agent['platform'] =~ /cisco/
      expected_facts.merge!({'dmi.product.serial_number' => /\w+/})
    end
    unless agent['platform'] =~ /windows|cisco|solaris/
      expected_facts.merge!({'dmi.board.asset_tag'     => /\w+|/,
                             'dmi.board.manufacturer'  => /\w+/,
                             'dmi.board.product'       => /\w+/,
                             'dmi.board.serial_number' => /None|\w+/
                            })
    end

    step("verify that dmi structured fact contains facts") do
      on(agent, facter("--json dmi")) do |facter_results|
        json_facts = JSON.parse(facter_results.stdout)
        expected_facts.each do |fact, value|
          actual_fact = json_result_fact_by_key_path(json_facts, fact)
          assert_match(value, actual_fact.to_s, "Incorrect fact pattern for '#{fact}'")
        end
      end
    end
  end
end
