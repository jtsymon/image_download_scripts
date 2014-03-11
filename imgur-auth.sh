#!/bin/bash

TTL=3600
client_id=imgur_client_id
client_secret=imgur_client_secret
refresh_token=imgur_refresh_token
access_token_file=~/.imgurAUTH

age=$[$(date +%s) - $(stat -c %Y $access_token_file)]
# echo $age
access_token=$(cat $access_token_file)
if [ "${#access_token}" -ne "40" ] || [ "$TTL" -lt "$age" ]; then
	access_token=$(curl -s -X POST -F "client_id=$client_id" -F "client_secret=$client_secret" -F "grant_type=refresh_token" -F "refresh_token=$refresh_token" https://api.imgur.com/oauth2/token | grep -o 'access_token":"[^"]*' | awk -F':"' '{print $2}')
	echo "$access_token" > `echo $access_token_file`
fi
