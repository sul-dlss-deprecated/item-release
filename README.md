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

Specify the environment you want to use:

bin/console development  

== Run a single robot on a specific ddruid

Specify the robot you want to run ("release-members" or "release-publish"), also specify environment with -e flag and druid with -d flag.
If you want to run multiple druids, instead of specifying a single druid with a -d flag, you can specify a text filename as a -f flag, with one druid per line.

bin/run_robot dor:releaseWF:release-publish -e development -d druid:bb027yn4436

== Deploy

cap development deploy
cap staging deploy
cap production deploy




