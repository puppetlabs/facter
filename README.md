Facter
======

This package is largely meant to be a library for collecting facts about your
system.  These facts are mostly strings (i.e., not numbers), and are things
like the output of `uname`, public ssh keys, the number of processors, etc.

See `bin/facter` for an example of the interface.

Running Facter
--------------

Run the `facter` binary on the command for a full list of facts supported on
your host.

Adding your own facts
---------------------

See the [Adding Facts](http://docs.puppetlabs.com/guides/custom_facts.html)
page for details of how to add your own custom facts to Facter.

Running Specs
-------------

* bundle install --path .bundle/gems
* bundle exec rake spec

Note: external facts in the system facts.d directory can cause spec failures.

Further Information
-------------------

See http://www.puppetlabs.com/puppet/related-projects/facter for more details.
