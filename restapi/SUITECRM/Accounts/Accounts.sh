QUERY='{{HOST}}/rest/{{VERSION}}/Accounts/'
QUERY+='&max_num=1'

# shellcheck disable=SC2089
CMD_OVERLOAD="--globoff --location --header 'Authorization: Bearer {{ACCESS_TOKEN}}'"

