{
  :type => 'aio',
  :pre_suite => [
    'setup/common/pre-suite/000-delete-puppet-when-none.rb',
    'setup/aio/pre-suite/010_Install.rb',
    'setup/aio/pre-suite/021_InstallAristaModule.rb',
  ],
}
