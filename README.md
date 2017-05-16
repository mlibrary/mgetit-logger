# MGetIt Logger

This is a very simple project to grab clickthrough events from the MGetIt
database and emit them to standard output on a rolling basis. It uses two
YAML files to control its operation:

 1. `config.yml` has the database connection information and a path to the
    timestamp file, used to keep track of the last point up to which the
    clickthroughs have been retrieved.
 1. `timestamp.yml` (the default name) has one value, which will be
    overwritten after the new events are emitted.

There is one runtime/production dependency, `mysql2`, and a few for
development. A standard `bundle install` should be all that is required.

Once configured, the app can be run periodically to extract the latest events
for redirecting to a file or another process. The default expectation is that
they will be sent to a file that is watched by Filebeat and logrotate.
