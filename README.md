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

[Installation and Setup](https://github.com/sensu-plugins/documentation/blob/master/user_docs/installation_instructions.md)

## Notes

