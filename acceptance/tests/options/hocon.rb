# This test is intended to ensure that the --hocon command-line option works
# properly. This option causes Facter to output facts in HOCON format.
test_name "--hocon command-line option results in valid HOCON output" do

  require 'hocon/parser/config_document_factory'
  require 'hocon/config_parse_options'
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils


  agents.each do |agent|
    step "Agent #{agent}: retrieve os fact data using the --hocon option" do
      on(agent, facter('--hocon os')) do
        begin
          parsing_successful = Hocon::Parser::ConfigDocumentFactory.parse_string(stdout.chomp, options =
            Hocon::ConfigParseOptions.defaults) != nil
          assert_equal(true, parsing_successful, "Output is not HOCON compatible.")
        rescue
          fail_test "Couldn't parse output as HOCON"
        end
      end
    end
  end
end

