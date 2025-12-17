#!/bin/bash

# Usage: ./listcompare.sh <old_app_server_id> <old_app> <new_app>

old_folder="/opt/nfs/sites_ecr$1/www/c/$2/custom/Extension/application/Ext/Language"
new_folder="/home/sites/www/v/$3/custom/Extension/application/Ext/Language"

old_files=("$old_folder"/*)

langs_excludes=(th_TH hr_HR)

output_file="list_compare.txt"
touch "$output_file"

for old_file in "${old_files[@]}"; do

  old_filename="$(basename "$old_file")"
  new_file="$new_folder/$old_filename"

  if [[ $old_filename == "$langs_excludes"* ]]; then
    continue
  fi

  if [ -f "$new_file" ]; then
    cmp --silent "$old_file" "$new_file"
    if [ $? -ne 0 ]; then
      echo "Differences for $old_filename:" >>$output_file
      diff -B -I '//.*' "$old_file" "$new_file" >>$output_file
      echo >>$output_file
    fi
  else
    echo "$old_filename does not exist in $new_folder" >>$output_file
  fi
done

echo "List of file differences is stored in $output_file"
