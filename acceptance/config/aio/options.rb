{
  :type => 'aio',
  :pre_suite => [
    'setup/common/pre-suite/000-delete-puppet-when-sparc.rb',
    'setup/aio/pre-suite/010_Install.rb',
  ],
}
