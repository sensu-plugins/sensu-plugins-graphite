## Sensu-Plugins-graphite

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-graphite.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-graphite)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-graphite.svg)](http://badge.fury.io/rb/sensu-plugins-graphite)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-graphite.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-graphite)
[ ![Codeship Status for sensu-plugins/sensu-plugins-graphite](https://codeship.com/projects/c6f4f5a0-db95-0132-445b-5ad94843e341/status?branch=master)](https://codeship.com/projects/79664)

## Functionality

## Files
 * bin/check-graphite-data
 * bin/check-graphite-replication
 * bin/check-graphite-stats
 * bin/check-graphite
 * bin/extension-graphite
 * bin/handlr-graphite-event
 * bin/hanlder-graphite-notify
 * bin/handler-graphite-occurances
 * bin/mutator-graphite

## Usage

**handler-graphite-event**
```
{
  "graphite_event": {
    "server_uri": "https://graphite.example.com:443/events/",
    "tags": [
      "custom_tag_a",
      "custom_tag_b"
    ]
  }
}
```

**handler-graphite-occurances**
```
{
 "graphite": {
    "server":"graphite.example.com",
    "port":"2003"
 }
}
```

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-graphite -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-graphite`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-graphite' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-graphite' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

## Notes

[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-graphite]
[2]:[http://badge.fury.io/rb/sensu-plugins-graphite]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-graphite]
