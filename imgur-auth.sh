#!/bin/bash

TTL=3600
client_id=imgur_client_id
client_secret=imgur_client_secret
auth_file=~/.imgurAUTH

if [[ -f $auth_file ]]; then
    age=$[$(date +%s) - $(stat -c %Y $auth_file)]
else
    touch $auth_file;
fi

# echo $age
auth=$(cat $auth_file)
refresh_token=$(echo "$auth" | sed '1q;d')
access_token=$(echo "$auth" | sed '2q;d')
if [[ "${#refresh_token}" -ne "40" ]] || [[ "${#access_token}" -ne "40" ]] || [[ "$TTL" -lt "$age" ]]; then
    response=$(curl -s -X POST -F "client_id=$client_id" -F "client_secret=$client_secret" -F "grant_type=refresh_token" -F "refresh_token=$refresh_token" https://api.imgur.com/oauth2/token)
    echo $response | grep -o 'refresh_token":"[^"]*' | awk -F':"' '{print $2}' > $auth_file
    echo $response | grep -o 'access_token":"[^"]*' | awk -F':"' '{print $2}' >> $auth_file
fi
