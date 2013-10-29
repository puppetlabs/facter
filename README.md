Facter
======

This package is largely meant to be a library for collecting facts about your
system.  These facts are mostly strings (i.e., not numbers), and are things
like the output of `uname`, public ssh keys, the number of processors, etc.

See `bin/facter` for an example of the interface.

Installation
------------

Generally, you need the following things installed:

* A supported Ruby version. Ruby 1.8.7, 1.9.3, and 2.0.0 (at least p195) are fully supported.

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

Support
-------
Please log tickets and issues at our [JIRA tracker](http://tickets.puppetlabs.com).  A [mailing
list](https://groups.google.com/forum/?fromgroups#!forum/puppet-users) is
available for asking questions and getting help from others. In addition there
is an active #puppet channel on Freenode.

We use semantic version numbers for our releases, and recommend that users stay
as up-to-date as possible by upgrading to patch releases and minor releases as
they become available.

Bugfixes and ongoing development will occur in minor releases for the current
major version. Security fixes will be backported to a previous major version on
a best-effort basis, until the previous major version is no longer maintained.


For example: If a security vulnerability is discovered in Facter 2.1.0, we
would fix it in the 2 series, most likely as 2.1.1. Maintainers would then make
a best effort to backport that fix onto the latest Facter 1.7 release.

Long-term support, including security patches and bug fixes, is available for
commercial customers. Please see the following page for more details:

[Puppet Enterprise Support Lifecycle](http://puppetlabs.com/misc/puppet-enterprise-lifecycle)
