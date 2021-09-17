#!/bin/bash
set -e
pg_config_dir=/pgconf
pg_bouncer_config=${pg_config_dir}/pgbouncer.ini
pg_users_list=${pg_config_dir}/users.txt
AUTH_TYPE=${AUTH_TYPE:-md5}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres}
DB_HOST=${DB_HOST:-postgres}
DB_PORT=${DB_PORT:-5432}

generate_pgbouncer_ini() {
cat <<EOF> ${pg_bouncer_config}
[databases]
* = host=${DB_HOST} port=${DB_PORT} auth_user=${DB_USER}

[pgbouncer]
listen_port = ${DB_PORT}
listen_addr = ${LISTEN_ADDR:-0.0.0.0}
auth_type = ${AUTH_TYPE}
auth_file = ${pg_users_list}
auth_query = SELECT username, password from pgbouncer.get_auth(\$1)
pidfile = /tmp/pgbouncer.pid
logfile = /dev/stdout
admin_users = root
stats_users = root, operator
default_pool_size = ${DEFAULT_POOL_SIZE:-50}
max_client_conn = ${MAX_CLIENT_CONN:-1000}
max_db_connections = ${MAX_DB_CONNECTIONS:-50}
min_pool_size = ${MIN_POOL_SIZE:-50}
pool_mode = ${POOL_MODE:-transaction}
reserve_pool_size = ${RESERVE_POOL_SIZE:-20}
reserve_pool_timeout = ${RESERVE_POOL_TIMEOUT:-240}
query_timeout = ${QUERY_TIMEOUT:-60}
ignore_startup_parameters = ${IGNORE_STARTUP_PARAMETERS:-extra_float_digits}
EOF
}

create_users_list() {
cat <<EOF> ${pg_users_list}
"${DB_USER}"     "${DB_PASSWORD}"
EOF
}

if [ ! -f "${pg_users_list}" ]
then
  echo -n "Creating ${pg_users_list}... "
  if [ "${AUTH_TYPE:-md5}" == "md5" ]
  then
    DB_PASSWORD="md5$(echo -n "$DB_PASSWORD$DB_USER" | md5sum | cut -f 1 -d ' ')"
  fi

  create_users_list

  if [ "$?" == 0 ]; then
    echo "done"
  else
    echo "failed"
  fi
else
  echo "Skipping. ${pg_users_list} already exists"
fi

if [ ! -f "${pg_bouncer_config}" ]
then
  echo -n "Creating ${pg_bouncer_config}... "
  generate_pgbouncer_ini

  if [ "$?" == 0 ]; then
    echo "done"
  else
    echo "failed"
  fi
else
  echo "Skipping. ${pg_bouncer_config} already exists"
fi

echo "Starting..."
exec "$@"
