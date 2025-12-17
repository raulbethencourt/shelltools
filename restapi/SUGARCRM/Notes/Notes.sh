QUERY='{{HOST}}/rest/{{VERSION}}/Notes/'
# QUERY+='?filter[0][%24and][0][parent_id]=1234-1234-1234'
# QUERY+='&filter[0][%24and][1][parent_type]=Note'
# QUERY+='&filter[0][%24and][2][%24or][0][note_type_c][%24not_equals]=doc'
# QUERY+='&filter[0][%24and][2][%24or][1][note_type_c]=%24is_null'
QUERY+='&max_num=1'

# shellcheck disable=SC2089
CMD_OVERLOAD="--globoff --location --request POST --header 'Content-Type: application/json' \
     --header 'Cookie: download_token_base=df18fd95-1453-41b2-9cf8-9bd7e22c0eb0'"
     
