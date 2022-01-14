#!/bin/bash

source config.sh

_DIR=$(pwd)

if [[ ! -d $_DIR/reports ]]; then
    echo "reports dir is not exists"
    exit 1
fi

FILES_DISABLED_USERS=($(find reports/users_disabled-*.*.csv))

# read file
# Source: https://www.baeldung.com/linux/csv-parsing#1-from-all-columns
for FILE_DISABLED_USERS in ${FILES_DISABLED_USERS[@]}; do
    echo $FILE_DISABLED_USERS
    while IFS="," read -r uid lastLoginDate
    do
        #TODO : delete users here with occ cli
        echo "uid : $uid"
        echo "last-login-date : $lastLoginDate"
        echo ""
    done < <(tail -n +2 $FILE_DISABLED_USERS)
done
