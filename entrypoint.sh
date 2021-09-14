#!/bin/bash
set -e
PG_CONFIG_DIR=${PG_CONFIG_DIR:-/pgconf}
PG_BOUNCER_CONFIG=${PG_CONFIG_DIR}/pgbouncer.ini
PG_USERS_LIST=${PG_CONFIG_DIR}/users.txt
AUTH_TYPE=${AUTH_TYPE:-md5}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres}

if [ ! -f "${PG_USERS_LIST}" ]
then
  echo -n "Creating ${PG_USERS_LIST}... "
  if [ "${AUTH_TYPE:-md5}" == "md5" ]; then
    DB_PASSWORD="md5$(echo -n "$DB_PASSWORD$DB_USER" | md5sum | cut -f 1 -d ' ')"
  fi

cat <<EOF> ${PG_USERS_LIST}
"${DB_USER}"     "${DB_PASSWORD}"
EOF

  if [ "$?" == 0 ]; then
    echo "done"
  else
    echo "failed"
  fi
else
  echo "Skipping. ${PG_USERS_LIST} already exists"
fi

if [ ! -f "${PG_BOUNCER_CONFIG}" ]
then
echo -n "Creating ${PG_BOUNCER_CONFIG}... "

cat <<EOF> ${PG_BOUNCER_CONFIG}
[databases]
* = host=${DB_HOST:-postgres} port=${DB_PORT:-5432} auth_user=${DB_USER:-postgres}

[pgbouncer]
listen_port = ${DB_PORT:-5432}
listen_addr = ${LISTEN_ADDR:-0.0.0.0}
auth_type = ${AUTH_TYPE:-md5}
auth_file = /pgconf/users.txt
auth_query = SELECT username, password from pgbouncer.get_auth(\$1)
pidfile = /tmp/pgbouncer.pid
logfile = /dev/stdout
admin_users = root
stats_users = root, operator
default_pool_size = ${DEFAULT_POOL_SIZE:-50}
max_client_conn = ${MAX_CLIENT_CONN:-1000}
max_db_connections = ${DEFAULT_POOL_SIZE:-50}
min_pool_size = ${DEFAULT_POOL_SIZE:-50}
pool_mode = ${POOL_MODE:-transaction}
reserve_pool_size = ${RESERVE_POOL_SIZE:-20}
reserve_pool_timeout = ${RESERVE_POOL_TIMEOUT:-240}
query_timeout = ${QUERY_TIMEOUT:-60}
ignore_startup_parameters = ${IGNORE_STARTUP_PARAMETERS:-extra_float_digits}
EOF

  if [ "$?" == 0 ]; then
    echo "done"
  else
    echo "failed"
  fi
else
  echo "Skipping. ${PG_BOUNCER_CONFIG} already exists"
fi

echo "Starting pgbouncer..."
exec "/usr/local/bin/pgbouncer ${PG_BOUNCER_CONFIG}"
