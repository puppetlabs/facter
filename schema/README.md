Facter Schema
=============

This directory contains a schema to document the types of facter built-in
facts. As new facts are added, this schema should be augmened to document
the type of the new facts.

Currently, this is used for acceptance testing.

Developer Validation
--------------------

As an aid to validation while developing a new fact, there is a simple
script `validate.rb`.  It takes no parameters and assumes it is run from
the root of the facter tree.

E.g. a successful run would look like:

    > schema/validate.rb
    Passed validation!

A failed run, after adding a new fact `brand_new_fact` but not updating the
schema, would look like:

    > schema/validate.rb
    The property '#/' contains additional properties ["brand_new_fact"] outside of the schema when none are allowed in schema c88b014f-e52a-5479-8720-916c32f56475#
    Failed validation.

A failed run, after introducing a regression by changing `changed_fact`
from an integer to a string, would look like:

    > schema/validate.rb
    The property '#/changed_fact' of type String did not match the following type: integer in schema d588f6fa-bc4a-5283-8830-23015f66c410#
    Failed validation.
