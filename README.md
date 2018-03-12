[![Build Status](https://travis-ci.org/sul-dlss/item-release.svg?branch=master)](https://travis-ci.org/sul-dlss/item-release)
[![Dependency Status](https://gemnasium.com/sul-dlss/item-release.svg)](https://gemnasium.com/sul-dlss/item-release)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/item-release/badge.svg?branch=add-coveralls-hound)](https://coveralls.io/github/sul-dlss/item-release?branch=add-coveralls-hound)

# Item Release Robot Suite

Robot suite that handles item release and updating PURLs to prepare for indexing.


## Documentation

Check the [Wiki](https://github.com/sul-dlss/robot-master/wiki) in the robot-master repo.

## Dependences

Ruby 2.2.2

## Setup

1. Install gems:

```console
$ bundle install
```

2. Copy the example.rb config file to a development file and so you can run in development mode:

```console
$ cp config/environments/example.rb config/environments/development.rb
```

3. Edit `config/environments/development.rb` to setup connections to actual dor-fetcher service and dor-workflow service and fedora

4. Puts certs to connect to fedora in the `config/certs` folder if you wish to make actual connections

## Running tests

External services are not called in the tests, everything is stubbed out, so you do not need actual connections to things.

```console
$ bundle exec rake
```

## Testing on the console

Specify the environment you want to use:

```console
$ bin/console development  
```

## Run a single robot on a specific druid

Specify the robot you want to run ("release-members" or "release-publish"), also specify environment with -e flag and druid with -d flag.

If you want to run multiple druids, instead of specifying a single druid with a -d flag, you can specify a text filename as a -f flag, with one druid per line.

```console
$ bin/run_robot dor:releaseWF:release-publish -e development -d druid:bb027yn4436
```

## Deploy

```console
$ cap dev deploy
$ cap stage deploy
$ cap prod deploy
```
