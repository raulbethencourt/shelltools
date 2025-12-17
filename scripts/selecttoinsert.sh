#!/bin/bash

help=1
while getopts "hs:p:l:w:" opt; do
  # shellcheck disable=SC2220
  case "$opt" in
  h) help=0 ;;
  s) server="$OPTARG" ;;
  p) loginPath="$OPTARG" ;;
  l) limit="$OPTARG" ;;
  w) where="$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

selectFields=""
mysql=$(which mysql)
[ -n "$1" ] && db="$1" || help=0    # db is obligatory
[ -n "$2" ] && table="$2" || help=0 # table is obligatory
fields="$3"                         # fields are optional

[ "$#" -eq 0 ] || [ "$help" -eq 0 ] && {
  cat <<EOF >&2
Usage: $0 [OPTION]... [DATABASE]... [TABLE]... [FIELDS]...
Recover data from select and create "INSERT INTO" query.

The database and the table are obligatory.
The fields list must be an quoted string separeted by spaces.

  -h  show this help and quit
  -s  make ssh query to remote server
  -p  use specific login-path (default = dockerroot)
  -l  query results limit (default = 50)
  -w  where clause for the mysql query (default = 1)

Examples:
  selecttoinsert some_db some_table
EOF
  exit 1
}

# =================
# BEGIN MAIN SCRIPT
# =================

if [ -z "$fields" ] || [ "$fields" = "*" ]; then
  # We create the query and we add ssh cmd si a server is given
  mysqlQueryDescribe="$mysql --login-path='${loginPath:-dockerroot}' -NLse 'use $db;describe $table;'"
  [ -n "$server" ] && mysqlQueryDescribe="ssh $server \"$mysqlQueryDescribe\"" # do command into server

  # Create list of fields for the select clause using the result of mysql describe query
  while IFS= read -r fieldDescription; do
    field=$(echo "$fieldDescription" | awk '{print $1}' 2>/dev/null)
    selectFields="$field, $selectFields"
  done < <(eval "$mysqlQueryDescribe" | tac) # Execute the mysql query and reorder fields
else
  # We build the mysql json object query with "'field', field" syntax
  for field in $fields; do
    selectFields="$field, $selectFields"
  done
fi

# Create query :
#   I remove last 2 characters to remove extra coma generated when
#   creating the list of fields
query=$(
  cat <<SQL
use $db;
select ${selectFields::-2}
from $table 
where ${where:-1}
limit ${limit:-1};
SQL
)

# TODO: create insert query from select...
selectResult=$(mysql --login-path="${loginPath:-dockerroot}" --max_allowed_packet=100M -e "$query")
echo "$selectResult" && exit 1

# We create the query and we add ssh cmd si a server is given
mysqlQueryJson="mysql --login-path='${loginPath:-dockerroot}' --max_allowed_packet=100M -NLse '$query'"
[ -n "$server" ] && mysqlQueryJson="ssh $server \"$mysqlQueryJson\"" # do command into server
eval "$mysqlQueryJson"                                               # Execute the mysql query

exit 0
