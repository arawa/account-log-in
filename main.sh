#!/bin/bash

source config.sh

USERS=($(sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:list | awk -F "-" '{ gsub(/ /,""); print $2}' | awk -F ":" '{print $1}'))

USERS_HAS_LOGGED=()

# Sort users enabled and disabled
for USER in ${USERS[@]}; do
    lastLogin=$(sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:lastseen $USER)
    if [ "$lastLogin" != "User $USER has never logged in, yet." ]
    then
        USERS_HAS_LOGGED+=($USER)
    fi
done

# Build an associative array with the user as key and date in second as value
# Example: [ foo ] => 1628773604
declare -A USERS_WITH_DATE

for USER in ${USERS_HAS_LOGGED[@]}; do
    DATE_LOGIN=$(sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:lastseen $USER | awk '{print $4}')
    YYYY=$(echo $DATE_LOGIN | cut -d '.' -f 3)
    MM=$(echo $DATE_LOGIN | cut -d '.' -f 2)
    DD=$(echo $DATE_LOGIN | cut -d '.' -f 1)
    USERS_WITH_DATE[$USER]=$YYYY-$MM-$DD
done

# Build an associative array (USERS_ARE_INACTIVES) who are inactives
declare -A USERS_ARE_INACTIVES
DATE_LIMIT=$(date -d "-$NUMBER_DAYS_TO_CHECK days" +%s)
for USER in "${!USERS_WITH_DATE[@]}"; do
    FORMAT_DATE=$(date -d ${USERS_WITH_DATE[$USER]} +%s)
    if [[ $DATE_LIMIT -gt $FORMAT_DATE ]]; then
        echo "$USER is inactive from ${USERS_WITH_DATE[$USER]}"
        USERS_ARE_INACTIVES[$USER]=${USERS_WITH_DATE[$USER]}
    fi
done

# Build a csv file
_DIR=$(pwd)

if [[ ! -d $_DIR/reports ]]; then
    mkdir $_DIR/reports
fi

TODAY=$(date "+%Y%m%d.%H%M")
if [[ ! -f $_DIR/reports/users_inactive-$TODAY.csv ]]; then
    touch $_DIR/reports/users_inactive-$TODAY.csv
fi


echo "uid,last-login-date" >> $_DIR/reports/users_inactive-$TODAY.csv

for USER in "${!USERS_ARE_INACTIVES[@]}"; do
    echo "$USER,${USERS_ARE_INACTIVES[$USER]}" >> $_DIR/reports/users_inactive-$TODAY.csv
done

echo ""
echo "It's done !"
echo "Your csv file of users innactives is here : $_DIR/reports/users_inactive-$TODAY.csv ."
