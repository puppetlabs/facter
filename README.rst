Facter
======

This package is largely meant to be a library for collecting facts about your
system.  These facts are mostly strings (i.e., not numbers), and are things
like the output of ``uname``, public ssh and cfengine keys, the number of
processors, etc.

See ``bin/facter`` for an example of the interface.

Running Facter
++++++++++++++

Run the ``facter`` binary on the command for a full list of facts supported on your host.

Adding your own facts
+++++++++++++++++++++

See the `Adding Facts`_ wiki page for details of how to add your own custom facts to Facter.
 
Further Information
+++++++++++++++++++

See http://reductivelabs.com/projects/facter/ for more details.

.. _Adding Facts: http://reductivelabs.com/trac/puppet/wiki/AddingFacts
