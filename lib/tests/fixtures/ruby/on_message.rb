def test_message(level, message)
    Facter.on_message do |lvl, msg|
        raise 'nope' unless level == lvl
        raise 'nope' unless message = msg
    end

    begin
        Facter.debug message if level == :debug
        Facter.warn message if level == :warn
    rescue Exception => ex
        Facter.on_message
    end
end

test_message(:debug, "debug message")
test_message(:warn, "warning message")
