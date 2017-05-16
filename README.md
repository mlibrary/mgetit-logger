# MGetIt Logger

This is a very simple project to grab clickthrough events from the MGetIt
database and emit them to standard output on a rolling basis. It uses three
optional YAML files to control its operation:

 1. `config.yml` has two keys, `database_file` and `timestamp_file` to point
    to the other two files, defaulting to the following names in the same
    directory. They can be named and located however the deployer chooses.
 1. `database.yml` has the database connection information. The values under
    the `database` key are passed directly to the `Mysql2::Client` constructor.
    The usual keys will be `host`, `username`, `password`, and `database`.
 1. `timestamp.yml` has one value, `last_time`, which will be
    overwritten after the new events are emitted. This is the last point up
    to which the clickthroughs have been retrieved.

All of these filenames are in `.gitignore` so that they are not checked in by
accident. There are `*.sample.yml` versions to serve as the basis for
custom versions.

There is one runtime/production dependency, `mysql2`, and a few for
development. A standard `bundle install` should be all that is required.

Once configured, the app can be run periodically to extract the latest events
for redirecting to a file or another process. The default expectation is that
they will be sent to a file that is watched by Filebeat and logrotate.
