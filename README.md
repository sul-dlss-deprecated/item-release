== Item Release Robot Suite

Robot suite that handles item release and updating PURLs to prepare for indexing.

== Dependences

Ruby 1.9.3

== Setup

bundle install

1. Edit config/environments/development.rb and test.rb file to setup connections to actual dor-fetcher service and dor-workflow service and fedora
2. Puts certs to connect to fedora in the config/certs folder

== Running tests

bundle exec rspec spec

== Testing on the console

bin/console development  


