# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]
### Added
- Change log (@haines)

### Fixed
- Require `rugged` explicitly (#6) (@haines)


## [0.2.1] - 2017-05-15
### Fixed
- Include vendored libraries in gem package (@haines)


## [0.2.0] - 2017-05-15 [YANKED]
### Changed
- Switch Rugged dependency from Red Badger's fork to released versions (at least 0.22.2 but before 0.25.0) (@tpickett66, @haines)
- Update vendored libraries (@haines)


## [0.1.1] - 2014-11-09
### Changed
- Stop requiring `rugged/backend` explicitly (@charypar)


## 0.1.0 - 2014-04-30
### Added
- `Rugged::Redis::Backend`: a Redis backend for Rugged (@charypar)


[Unreleased]: https://github.com/redbadger/rugged-redis/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/redbadger/rugged-redis/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/redbadger/rugged-redis/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/redbadger/rugged-redis/compare/v0.1.0...v0.1.1
