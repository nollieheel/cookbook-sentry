## 0.1.3 - 2016-11-03
### Fixed
- In supervisor service for sentry_worker, added '%(process_num)d' in process_name when numprocs is more than 1.

## 0.1.2 - 2016-10-27
### Added
- Versions on the default Sentry plugins

## 0.1.1 - 2016-10-26
### Added
- Attribute to set concurrency for sentry worker (default is number of processors in machine).
- Attribute to set 'numprocs' for worker supervisor config (default is 1).
- Default Redis optimization options according to https://docs.sentry.io/server/performance/.

## 0.1.0 - 2016-10-26
### Added
- Initial working version of the cookbook

---
Changelog format reference: http://keepachangelog.com/en/0.3.0/
