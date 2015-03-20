# This Dockerfile uses Coverity, which requires a project and authentication token.
# Since it's based off the cfacter builder, we hard-code the project; the authentication
# token should remain secret, so it's required as an argument when starting the builder.
# Other optional arguments also exist to select a branch to build.
# Docker startup arguments (required if no default):
# - COV_NAME: coverity scan name
# - COV_USERID: coverity scan user id
# - COV_EMAIL: coverity scan e-mail
# - COV_TOKEN: the authentication token
# - COV_FORK: the github fork, defaults to puppetlabs
# - COV_BRANCH: the branch, defaults to master
# - COV_JOBS: number of parallel jobs to run for the build, defaults to 1

# Setup environment
FROM mikaelsmith/travis-cfacter-builder:12.04
MAINTAINER Michael Smith <michael.smith@puppetlabs.com>

# Setup coverity scan
RUN git clone https://gitorious.org/coverity-submit/coverity-submit.git
ADD fix_curl_command.patch /tmp/fix_curl_command.patch
RUN cd coverity-submit &&\
    git am --signoff < /tmp/fix_curl_command.patch &&\
    make install &&\
    cd .. &&\
    rm -r coverity-submit /tmp/fix_curl_command.patch
ADD _coverity-submit.erb /root/.coverity-submit.erb

# Setup and run coverity build
CMD wget --quiet https://scan.coverity.com/download/linux-64 --post-data "token=${COV_TOKEN}&project=puppetlabs%2Fcfacter" -O coverity_tool.tgz; \
    tar xzf coverity_tool.tgz --strip 1 -C /usr/local; \
    rm coverity_tool.tgz; \
    erb /root/.coverity-submit.erb > /root/.coverity-submit; \
    cd /root/cfacter; \
    if [ -z "$COV_FORK" ]; then export COV_FORK=puppetlabs; else git remote set-url origin https://github.com/${COV_FORK}/cfacter; fi; \
    git fetch origin; \
    if [ -z "$COV_BRANCH" ]; then export COV_BRANCH=master; else git checkout $COV_BRANCH; fi; \
    git pull origin $COV_BRANCH; \
    if [ -z "$COV_JOBS" ]; then export COV_JOBS=1; fi; \
    coverity-submit puppetlabs%2Fcfacter

