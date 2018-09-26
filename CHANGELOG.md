# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]
### Fixed
- handler-graphite-status.rb: use proper rescue class (@MrMisa93)
- handler-graphite-notify.rb: use proper rescue class (@majormoses)

## [3.1.0] - 2018-02-28
### Added
- Added -t flag to handler-graphite-event.rb to support post 1.0 versions of graphite which require tags sent as arrays. (@jwatroba)

### Changed
- updated Changelog guidelines location (@majormoses)

### Fixed
- minor typos in PR template (@majormoses)

## [3.0.0] - 2017-12-04
### Breaking Change
- bumped dependency of `sensu-plugin` to 2.x you can read about it [here](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#v200---2017-03-29)

## [2.3.0] - 2017-10-19
### Added
- example in readme for using the handlers (@scosist)
### Changed
- Added option -j to handler-graphite-notify.rb and handler-graphite-status.rb to allow configuration scope to be defined on command line.

## [2.2.1] - 2017-06-13
### Fixed
- Remove short options -s on hostname_sub, it was unusable. This affects check-graphite-data and check check-graphite-hosts

## [2.2.0] - 2017-06-11
### Removed
- check-graphite-data.rb: Removed unused method `retrieve_data` since it's duplicate from graphite_proxy

## [2.1.0] - 2017-06-11
### Changed
- Disable filtering for handler-graphite-status.rb
### Fixed
- Error handling in graphite handlers
- Duplicate short option in check-graphite.rb

## [2.0.0] - 2016-06-21
### Added
- Added handler-graphite-status.rb to create metric which gives the status of the sensu check when it changes state (0,1,2,3)

### Changed
- Updated sensu-plugin dependency to use a pessimistic version constraint

### Fixed
- Correct error message for incorrect graphite expression

### Removed
- Remove Ruby 1.9.3 support; add Ruby 2.3.0 support

## [1.1.0] - 2016-04-26
### Fixed
- fix comparison of number against array in --last.
- improve wording of --last help text.

## [1.0.0] - 2016-01-20
### Changed
- Use the whole client name as hostname for graphite measurement

## [0.0.7] - 2015-09-29
### Added
- add -r option (Reverse the warning/crit scale (if value is less than instead of greater than)) to check-graphite-stats.rb

### Changed
- The short command line option for 'Add an auth token to the HTTP request' is now -A, -a clashed with the proxy support
- Set socket's SSL mode only if using HTTPS

## [0.0.6] - 2015-08-27
### Added
- check on number of hosts
- -auth param allows authentication by bearer token

## [0.0.5] - 2015-08-05
### Changed
- general cleanup

## [0.0.4] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.3] - 2015-06-16
### Fixed
- removed outdated dependency on openssl

## [0.0.2] - 2015-06-02
### Fixed
- added binstubs
### Changed
- removed cruft from /lib

## 0.0.1 - 2015-04-30
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/3.1.0...HEAD
[3.1.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/2.2.1...3.0.0
[2.3.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/2.2.1...2.3.0
[2.2.1]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.7...1.0.0
[0.0.7]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.6...0.0.7
[0.0.6]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-graphite/compare/0.0.1...0.0.2
