QUERY='{{HOST}}/rest/{{VERSION}}/oauth2/token'

# shellcheck disable=SC2089
CMD_OVERLOAD="--globoff --location --request POST --header 'Content-Type: application/json' \
     --header 'Cookie: download_token_base=df18fd95-1453-41b2-9cf8-9bd7e22c0eb0' \
     --data-raw '{
         \"grant_type\": \"refresh_token\",
         \"refresh_token\": \"{{REFRESH_TOKEN}}\",
         \"client_id\": \"{{CLIENT_ID}}\",
         \"client_secret\": \"{{CLIENT_SECRET}}\",
         \"plataform\": \"{{PLATAFORM}}\"
     }'"

