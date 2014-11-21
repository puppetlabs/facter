begin
    # Log without tracing
    Facter.trace false
    begin
        raise 'first'
    rescue Exception => ex
        Facter.log_exception ex
    end

    # Can be set
    Facter.trace true
    raise 'nope' unless Facter.trace?

    # Log with tracing
    begin
        raise 'second'
    rescue Exception => ex
        Facter.log_exception ex
    end
ensure
    Facter.trace false
end
