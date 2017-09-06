## Sensu-Plugins-graphite

[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-graphite.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-graphite)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-graphite.svg)](http://badge.fury.io/rb/sensu-plugins-graphite)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graphite)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-graphite.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-graphite)

## Functionality

## Files
 * bin/check-graphite-data
 * bin/check-graphite-replication
 * bin/check-graphite-stats
 * bin/check-graphite
 * bin/extension-graphite
 * bin/handler-graphite-event
 * bin/handler-graphite-notify
 * bin/handler-graphite-status
 * bin/handler-graphite-occurrences
 * bin/mutator-graphite

## Usage

### handler-graphite-event
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

### handler-graphite-occurrences
```
{
 "graphite": {
    "server":"graphite.example.com",
    "port":"2003"
 }
}
```

### handler-graphite-notify
```
{
 "graphite_notify": {
    "host":"graphite.example.com",
    "port":"2003",
    "prefix":"sensu.events"
 }
}
```

### handler-graphite-status
```
{
 "graphite_status": {
    "host":"graphite.example.com",
    "port":"2003",
    "prefix":"sensu.events"
 }
}
```

## Full Configuration Example
+**Note that TCP Handler is preferred**
```
{
  "graphite_event": {
    "server_uri": "https://graphite.example.com:443/events/",
    "tags": [
      "custom_tag_a",
      "custom_tag_b"
    ]
  },
  "handlers":
  {
    "default": {
      "type": "set",
      "handlers": [
        "graphite_event"
      ]
    },
    "graphite_tcp": {
      "type": "tcp",
      "socket": {
        "host":"graphite.example.com",
        "port":2003
      },
      "mutator": "only_check_output"
    },
    "graphite_event": {
      "type": "pipe",
      "filters": [
        "custom_filter_a",
        "custom_filter_b"
      ],
      "command": "handler-graphite-event.rb"
    }
  },
  "checks": {
    "metrics_uptime": {
      "standalone": true,
      "type": "metric",
      "handlers": [
        "graphite_tcp"
      ],
      "interval": 60,
      "command": "metrics-uptime.rb --scheme sensu.host.$(hostname).uptime",
      "subscribers": [
        "core"
      ]
    }
  }
}
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
