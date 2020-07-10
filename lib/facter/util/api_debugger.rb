# frozen_string_literal: true

module ApiDebugger
  def self.prepended(receiver) # rubocop:disable Metrics/AbcSize
    exclude, print_caller = parse_options(ENV['API_DEBUG'])

    receiver_methods = receiver.instance_methods - Object.methods
    receiver_methods.each do |meth|
      ApiDebugger.class_eval do
        define_method(meth) do |*args|
          method_call = super(*args)

          unless exclude.include?(meth)
            puts '#' * 80
            puts "Method call: #{meth}"
            puts "Called with: #{args.inspect}"
            if print_caller.include?(meth)
              puts '-' * 80
              puts caller
            end
            puts '#' * 80
          end
          method_call
        end
      end
    end
  end

  def self.parse_options(options)
    exclude = []
    print_caller = []

    options.split(',').each do |option|
      if option.start_with?('-')
        exclude << option[1..-1].to_sym
      elsif option.start_with?('+')
        print_caller << option[1..-1].to_sym
      end
    end

    [exclude, print_caller]
  end
end
