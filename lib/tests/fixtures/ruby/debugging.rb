begin
    # Log without debugging
    Facter.debugging false
    Facter.debug 'nope'

    # Can be set
    Facter.debugging true
    raise 'nope' unless Facter.debugging?

    # Log with debugging
    Facter.debug 'yep'
ensure
    Facter.debugging false
end
