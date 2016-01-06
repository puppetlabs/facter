{
  :type          => 'aio',
  :forge_host    => 'forge-aio01-petest.puppetlabs.com',
  :load_path     => './lib/',
  :repo_proxy    => true,
  :add_el_extras => true,
  :pre_suite     => [
    'setup/common/pre-suite/000-delete-puppet-when-none.rb',
    'setup/aio/pre-suite/010_Install.rb',
    'setup/aio/pre-suite/021_InstallAristaModule.rb',
  ],
}
