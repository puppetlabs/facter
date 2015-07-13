{
  :type => 'aio',
  :pre_suite => [
    'setup/peaio/pre-suite/010_Install.rb',
  ],
  # :pe_dir needed to get LATEST PE version, which is a part
  # of the puppet-agent URL.  puppet-agent will be installed
  # from the pe_promoted_repo, not from here, however.
  :pe_dir => 'http://neptune.puppetlabs.lan/4.0/ci-ready',
}
