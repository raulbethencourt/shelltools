#!/bin/bash

LOGIN_PATH="loginpath"

DB1=$1
DB2=$2

MARKDOWN_FILE="missing_tables_and_fields.md"

echo "# List of missing tables and fields" >$MARKDOWN_FILE

get_tables() {
  local database="$1"

  mysql --login-path=$LOGIN_PATH -Ne "use $database; show tables;" | awk '{print $1}'
}

get_fields() {
  local database="$1"
  local table="$2"

  mysql --login-path=$LOGIN_PATH -Ne "use $database; describe $table;" | awk '{print $1}'
}

tables_db1=$(get_tables $DB1)
tables_db2=$(get_tables $DB2)

missing_fields_db2_to_db1=""
for table in $tables_db1; do
  fields_db2=$(get_fields $DB2 $table)
  fields_db1=$(get_fields $DB1 $table)

  for field in $fields_db1; do
    if ! echo "$fields_db2" | grep -q -w "$field"; then
      missing_fields_db2_to_db1+="- Table: $table, Field: $field;"
    fi
  done
done
missing_fields_db2_to_db1=$(echo $missing_fields_db2_to_db1 | tr ';' '\n')

echo "" >>$MARKDOWN_FILE
echo "## Missing fields" >>$MARKDOWN_FILE
echo "" >>$MARKDOWN_FILE
echo "### Fields missing in $DB2 and present in $DB1:" >>$MARKDOWN_FILE
echo "$missing_fields_db2_to_db1" >>$MARKDOWN_FILE

echo "Markdown file '$MARKDOWN_FILE' generated successfully."
