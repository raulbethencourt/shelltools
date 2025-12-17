QUERY='{{HOST}}//artworks/search'

# shellcheck disable=SC1083
CMD_OVERLOAD="--location --request POST \
--header 'Content-Type: application/json' \
--data-raw '{
    \"q\": \"cats\",
    \"query\": {
        \"term\": {
            \"is_public_domain\": true
        }
    }
}'"

