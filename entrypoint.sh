#!/bin/bash
set -e
pg_config_dir=/pgconf
pg_bouncer_config=${pg_config_dir}/pgbouncer.ini
pg_users_list=${pg_config_dir}/users.txt
pg_auth_type=${PGBOUNCER_AUTH_TYPE:-md5}
pg_user=${POSTGRESQL_USER:-postgres}
pg_password=${POSTGRESQL_PASSWORD:-postgres}
pg_host=${POSTGRESQL_HOST:-postgresql}
pg_port=${PGBOUNCER_PORT:-5432}

generate_pgbouncer_ini() {
cat <<EOF> ${pg_bouncer_config}
[databases]
${PGBOUNCER_DATABASE} = host=${pg_host} port=${pg_port} auth_user=${pg_user}

[pgbouncer]
listen_port = ${pg_port}
listen_addr = ${PGBOUNCER_BIND_ADDRESS:-0.0.0.0}
auth_type = ${pg_auth_type}
auth_file = ${pg_users_list}
auth_query = SELECT username, password from pgbouncer.get_auth(\$1)
pidfile = /tmp/pgbouncer.pid
logfile = /dev/stdout
admin_users = ${pg_user}
stats_users = ${pg_user}
min_pool_size = ${PGBOUNCER_MIN_POOL_SIZE:-0}
default_pool_size = ${PGBOUNCER_DEFAULT_POOL_SIZE:-20}
max_client_conn = ${PGBOUNCER_MAX_CLIENT_CONN:-120}
max_db_connections = ${PGBOUNCER_MAX_DB_CONNECTIONS:-0}
pool_mode = ${PGBOUNCER_POOL_MODE:-transaction}
reserve_pool_size = ${PGBOUNCER_RESERVE_POOL_SIZE:-0}
reserve_pool_timeout = ${RESERVE_POOL_TIMEOUT:-30}
query_timeout = ${QUERY_TIMEOUT:-60}
idle_transaction_timeout = ${PGBOUNCER_IDLE_TRANSACTION_TIMEOUT:-0}
ignore_startup_parameters = ${PGBOUNCER_IGNORE_STARTUP_PARAMETERS:-extra_float_digits}
EOF
}

create_users_list() {
cat <<EOF> ${pg_users_list}
"${pg_user}"     "${pg_password}"
EOF
}

if [ ! -f "${pg_users_list}" ]
then
  echo -n "Creating ${pg_users_list}... "
  if [ "${pg_auth_type}" == "md5" ]
  then
    pg_password="md5$(echo -n "$pg_password$pg_user" | md5sum | cut -f 1 -d ' ')"
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
