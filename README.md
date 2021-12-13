# PG Bouncer
This repository intends to build a pgbouncer image that is based on Red Hat UBI images for use with certified operators.

## Environment Variables

- `POSTGRESQL_USER` - The name of the user pgbouncer will use to connect to postgresql instance

- `POSTGRESQL_PASSWORD` - The password of the user pgbouncer will use to connect to postgresql instance

- `POSTGRESQL_PORT` - The port pgbouncer will listen for connections on

- `POSTGRESQL_HOST` - The postgresql instance to connect to

- `PGBOUNCER_AUTH_TYPE` - the protocol to use to authenticate users 

- `DEFAULT_POOL_SIZE` - 

- `PGBOUNCER_IGNORE_STARTUP_PARAMETERS` - this is a list of parameters pgbouncer can not track in startup packets

- `QUERY_TIMEOUT` - queries running longer that this value will be cancelled

- `RESERVE_POOL_TIMEOUT` - use additional connections from reserve pool if a client has not been serviced in this many seconds

- `PGBOUNCER_RESERVE_POOL_SIZE` - the number of additional connections to allow to a pool

- `PGBOUNCER_POOL_MODE` - the pool mode specific to this database

- `PGBOUNCER_DEFAULT_POOL_SIZE` - the number of connections to allow per user/database pair

- `PGBOUNCER_BIND_ADDRESS` - the address to which pgbouncer will bind to

- `PGBOUNCER_MAX_CLIENT_CONN` - maximum number of client connections allowed

- `PGBOUNCER_MAX_DB_CONNECTIONS` - maximum number of server connections to allow per user regardless of database

- `PGBOUNCER_MIN_POOL_SIZE` - minimum pool size for the database

- `PGBOUNCER_DATABASE` - database for which the credentials allow access to
