QUERY='{{HOST}}/rest/{{VERSION}}/Contacts/'
# QUERY+='?fields=field_name'
QUERY+='&max_num=1'

# shellcheck disable=SC2089
CMD_OVERLOAD="--globoff --location --header 'Authorization: Bearer {{ACCESS_TOKEN}}'"

