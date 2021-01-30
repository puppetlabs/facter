
# How to contribute

Third-party patches are essential for keeping facter great. We simply can't
access the huge number of platforms and myriad configurations for running
Facter. We want to keep it as easy as possible to contribute changes that
get things working in your environment. There are a few guidelines that we
need contributors to follow so that we can have a chance of keeping on
top of things.

## Getting Started

* Make sure you have a [Jira account](https://tickets.puppetlabs.com).
* Make sure you have a [GitHub account](https://github.com/signup/free).
* Submit a Jira ticket for your issue if one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
  * A ticket is not necessary for [trivial changes](https://puppet.com/community/trivial-patch-exemption-policy)
* Fork the repository on GitHub.

## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the `main` branch.
  * Once merged, your work will be automatically promoted to the other release
    streams when our internal CI passes.
  * To quickly create a topic branch based on main, run `git checkout -b
    fix/main/my_contribution main`. Please avoid working directly on the
    `main` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format. We use the [50/72 rule](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project) in commit messages.
* If the commit addresses an issue filed in the [Facter Jira project](https://tickets.puppetlabs.com/browse/FACT), start the first line of the commit with the issue number in parentheses.

````
    (FACT-1234) Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied the example commit message in the CONTRIBUTING
    document is not a concrete example.  This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example.  This patch fixes the
    problem by making the example concrete and imperative.

    The first line is a real life imperative statement with a ticket number
    from our issue tracker.  The body describes the behavior without the patch,
    why this is a problem, and how the patch fixes the problem when applied.
````

* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.
  * We recommend running `./check.sh` to have the same checks run as on github

## Making Trivial Changes

For [changes of a trivial nature](https://puppet.com/community/trivial-patch-exemption-policy), it is not always necessary to create a new
ticket in Jira. In this case, it is appropriate to start the first line of a
commit with one of  `(docs)` or `(maint)` instead of a ticket number.

If a Jira ticket exists for the documentation commit, you can include it
after the `(docs)` token.

```
    (docs)(DOCUMENT-000) Add docs commit example to CONTRIBUTING

    There is no example for contributing a documentation commit
    to the Facter repository. This is a problem because the contributor
    is left to assume how a commit of this nature may appear.

    The first line is a real-life imperative statement with '(docs)' in
    place of what would have been the FACT project ticket number in a
    non-documentation related commit. The body describes the nature of
    the new documentation or comments added.
```

For commits that address trivial repository maintenance tasks start the first line of the commit with `(maint)`

## Submitting Changes

* Sign the [Contributor License Agreement](http://links.puppet.com/cla).
* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to the repository in the puppetlabs organization.
* Update your ticket to mark that you have submitted code and are ready for it to be reviewed.
  * Include a link to the pull request in the ticket

# Additional Resources

* [Puppet community guidelines](https://puppet.com/community/community-guidelines/)
* [Bug tracker (Jira)](https://tickets.puppetlabs.com/browse/FACT)
* [Contributor License Agreement](http://links.puppet.com/cla)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
* [puppet-dev mailing list](https://groups.google.com/forum/#!forum/puppet-dev)
* [Puppet-dev Slack channel](https://puppetcommunity.slack.com/archives/C0W1X7ZAL)
