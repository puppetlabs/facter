module Facter
  module Acceptance
    module ApiUtils
      # create a facter_run.rb file that loads facter,
      # register a teardown that will clear the executable dir
      # set different config options(debug, custom/external dir)
      # print the result of Facter.value
      def facter_value_rb(agent, fact_name, options = {})
        dir = agent.tmpdir('executables')

        teardown do
          agent.rm_rf(dir)
        end

        rb_file = File.join(dir, 'facter_run.rb')

        file_content = <<-RUBY
          require 'facter'

          Facter.debugging(#{options.fetch(:debug, false)})
          Facter.search('#{options.fetch(:custom_dir, '')}')
          Facter.search_external(['#{options.fetch(:external_dir, '')}'])

          puts Facter.value('#{fact_name}')
        RUBY

        create_remote_file(agent, rb_file, file_content)
        rb_file
      end
    end
  end
end
