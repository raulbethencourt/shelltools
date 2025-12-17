QUERY='{{HOST}}/Api/access_token'

# shellcheck disable=SC2089
CMD_OVERLOAD="--header 'Content-Type: application/vnd.api+json' \
--header 'Accept: application/vnd.api+json' \
--data-raw '{ 
  \"grant_type\": \"refresh_token\", 
  \"refresh_toke\": \"{{REFRESH_TOKEN}}\",
  \"client_id\": \"{{CLIENT_ID}}\", 
  \"client_secret\": \"{{CLIENT_SECRET}}\",
  \"plataform\": \"{{PLATAFORM}}\"
}'"

