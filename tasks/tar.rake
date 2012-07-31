def get_version
  %x{which git &> /dev/null}
  if $?.success?
    `git describe`.strip
  else
    File.read('lib/facter.rb')[/FACTERVERSION *= *'(.*)'/,1] or fail "Couldn't find FACTERVERSION"
  end
end

namespace :package do
  desc "Create a source tar archive"
  task :tar => [ :clean, :build_environment ] do
    workdir = "pkg/#{@name}-#{@version}"
    mkdir_p workdir
    FileList[ '[A-Z]*', 'install.rb', 'bin', 'lib', 'ext', 'etc', 'spec' ].each do |f|
      cp_pr f, workdir
    end
    erb "#{workdir}/ext/redhat/#{@name}.spec.erb", "#{workdir}/ext/redhat/#{@name}.spec"
    erb "#{workdir}/ext/debian/changelog.erb", "#{workdir}/ext/debian/changelog"
    rm_rf FileList["#{workdir}/ext/debian/*.erb", "#{workdir}/ext/redhat/*.erb"]
    cd "pkg" do
      sh "tar --exclude=.gitignore -zcf #{@name}-#{@version}.tar.gz #{@name}-#{@version}"
    end
    rm_rf workdir
    puts
    puts "Wrote #{`pwd`.strip}/pkg/#{@name}-#{@version}"
  end
end
