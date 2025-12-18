#!/bin/bash

# Initialize library
source "$SHELLTOOLSPATH"/lib/.toolbox

parse_options 0 JSQL_ \
  "--usage: Recover data from mysql table and transform it to json array. \
\n The database and the table are obligatory.\n \
${purplef}E.g${reset} ${greenf}$(basename "$0")${reset} [OPTION]... [DATABASE]... [TABLE]... [FIELDS]..." \
  "--server:s=:Make ssh query to remote server." \
  "--db:d=:Use this database to do the search." \
  "--table:t=:Use this table to do the search. Is completely necesary to have use a db to do the search." \
  "--fields:f=:The fields to search into the table. Is completely necesary to have a db and table to do the search." \
  "--where:w=|default=1:put here any where condition that will be added. The where is a string used as provided in an sql select. If defined the command will test that there is at least one matching record." \
  "--limit:l=|default=50:query results limit." \
  "--examples:    ${greenf}jsql${reset} -L some_login_path\n \
        ${greenf}jsql${reset} -L some_login_path -d some_db\n \
        ${greenf}jsql${reset} -s f1 -L some_login_path -l 2 -f \"field1 field2\" -d some_db -t some_table | jq" \
  -- "$@"
shift "$((TBOPTIND))"

# Validate database name (only alphanumeric, underscore and hyphen allowed)
[[ -n "$JSQL_DB" ]] && {
  [[ "$JSQL_DB" =~ ^[a-zA-Z0-9_-]+$ ]] || print_usage
}
# Validate table name (only alphanumeric, underscore and hyphen allowed)
[[ -n "$JSQL_TABLE" ]] && {
  [[ "$JSQL_TABLE" =~ ^[a-zA-Z0-9_-]+$ ]] || print_usage
}
# Validate table fields (only alphanumeric, underscore, space, comma and hyphen allowed)
[[ -n "$JSQL_FIELDS" ]] && {
  [[ "$JSQL_FIELDS" =~ ^[a-zA-Z0-9_,[:space:]*-]+$ ]] || print_usage
}

# Validate that we have all data we need for different queries
[[ -n "$JSQL_TABLE" ]] && [[ -z "$JSQL_DB" ]] && error_exit "You need to specify a database to do the search."
[[ -n "$JSQL_FIELDS" ]] && [[ -z "$JSQL_TABLE" ]] && error_exit "You need to specify a database and a table to do the search."

# Validate where clause for basic SQL injection prevention
! [[ "$JSQL_WHERE" =~ ^[[:alnum:]_[:space:]=\>\<\.\'\"%-]+$ ]] && error_exit "Invalid WHERE clause" 2

# Validate where clause for basic SQL injection prevention
! [[ "$JSQL_LIMIT" =~ ^[[:digit:]]+$ ]] && error_exit "Invalid LIMIT value" 2

jsonFields=""
mysql=$(which mysql) # get our mysql version bin
[ ! -x "$mysql" ] && error_exit "MySQL client not found. Please install MySQL client."

# =================
# BEGIN MAIN SCRIPT
# =================

if [ -n "$JSQL_TABLE" ]; then
  # Create the select query base in given fields or discribe query
  if [ -z "$JSQL_FIELDS" ] || [ "$JSQL_FIELDS" = "*" ]; then
    # We create the query and we add ssh cmd si a server is given
    mysqlQueryDescribe="$mysql --login-path=$LOGIN_PATH --max_allowed_packet=100M \
    --connect-timeout=10 -NLse 'use $JSQL_DB;describe $JSQL_TABLE;'"

    [ "$VERBOSE" -gt 1 ] && printf '%s\n%s\n' "MySQL Describe Query :" "$mysqlQueryDescribe"

    [ -n "$JSQL_SERVER" ] && mysqlQueryDescribe="ssh $JSQL_SERVER \"$mysqlQueryDescribe\"" # do command into server

    # Create list of fields for json_object using the result of mysql describe query
    while IFS= read -r fieldDescription; do
      field=$(echo "$fieldDescription" | awk '{print $1}' 2>/dev/null)
      jsonFields="'$field',$field,$jsonFields"
    done < <(eval "$mysqlQueryDescribe" | tac) || error_exit "Mysql error in describe query." # Execute the mysql query and reorder fields
  else
    # We build the mysql json object query with "'field', field" syntax
    for field in $JSQL_FIELDS; do
      jsonFields="'$field',$field,$jsonFields"
    done
  fi

  query=$(
    cat <<SQL
use $JSQL_DB;
select json_arrayagg(jsonObj)
from
(
  select json_object(${jsonFields::-1}) as jsonObj
  from $JSQL_TABLE
  where $JSQL_WHERE
  limit $JSQL_LIMIT
) t;
SQL
  )
elif [ -n "$JSQL_DB" ]; then
  # Show tables from database as JSON array
  query=$(
    cat <<SQL
use $JSQL_DB;
select json_arrayagg(table_name) as json_result
from information_schema.tables
where table_schema = '$JSQL_DB';
SQL
  )
else
  # Show databases as JSON array
  query=$(
    cat <<SQL
select json_arrayagg(schema_name) as json_result
from information_schema.schemata
where schema_name not in ('information_schema', 'performance_schema', 'mysql', 'sys');
SQL
  )
fi

[ "$VERBOSE" -gt 1 ] && printf '%s\n%s\n' "MySQL Query :" "$query"

mysqlCmd="$mysql --login-path=$LOGIN_PATH --max_allowed_packet=100M --connect-timeout=10 -NLs"

# We create the query and we add ssh cmd si a server is given
if [ -n "$JSQL_SERVER" ]; then
  # Use base64 encoding to avoid quote issues entirely
  encodedQuery=$(echo "$query" | base64 -w 0)
  queryResult=$(ssh "$JSQL_SERVER" "echo '$encodedQuery' | base64 -d | $mysqlCmd") ||
    error_exit "SSH MySQL query failed on server $JSQL_SERVER" 2
else
  queryResult=$(echo "$query" | $mysqlCmd) || error_exit "Local MySQL query failed " 2
fi

# Parsing result for proper json
json=$(echo "$queryResult" | tr -d '\r\n') # Strip line breaks
# Fix double-escaped newlines, double-escaped carriage returns, escaped quotes, double-escaped quotes
json=$(echo "$json" | sed 's/\\\\n/\\n/g; s/\\\\r/\\r/g; s/\\\"/"/g; s/\\\\"/\\"/g')
json=$(echo "$json" | sed -E 's/([a-zA-Z0-9_-]+)="([^"]*)"/\1=\"\2\"/g') # Ensure HTML attributes are properly formatted

# Try to strip any extraneous characters outside the main JSON array
[[ "$json" =~ \[(.*)\] ]] && json="[${BASH_REMATCH[1]}]"

echo "$json"

exit 0
