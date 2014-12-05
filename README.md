== Item Release Robot Suite

Robot suite that handles item release and updating PURLs to prepare for indexing.

== Dependences

Ruby 1.9.3

== Setup

1. Install gems:

bundle install

2. Copy the example.rb config file to a development file and so you can run in development mode:

cp config/environments/example.rb config/environments/development.rb

3. Edit config/environments/development.rb to setup connections to actual dor-fetcher service and dor-workflow service and fedora

4. Puts certs to connect to fedora in the config/certs folder if you wisjh to make actual connections

== Running tests

External services are not called in the tests, everything is stubbed out, so you do not need actual connections to things.

bundle exec rspec spec

== Testing on the console

bin/console development  


