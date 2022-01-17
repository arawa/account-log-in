#!/bin/bash

if [ -z "$1" ]; then
    echo "No argument."
    echo "You should define the absolute path of your CSV file."
    echo "For example : bash ./disable-users.sh /home/foobar/projets/account-log-in/reports/users_inactive-20220117.1102.csv"
    exit
fi

source config.sh

_DIR=$(pwd)

if [[ ! -d $_DIR/reports ]]; then
    echo "reports dir is not exists"
    exit 1
fi

FILE_INACTIVE_USERS=$1
DATE_LIMIT=$(date -d "-$NUMBER_DAYS_TO_CHECK days" +%s)

# Build disabled csv file
TODAY=$(date "+%Y%m%d.%H%M")
echo "uid,last-login-date" >> $_DIR/reports/users_disabled-$TODAY.csv

# Disabled users who aren't log in from than 3 month (30 days).
# read file
# Source: https://www.baeldung.com/linux/csv-parsing#1-from-all-columns
for FILE_INACTIVE_USERS in ${FILE_INACTIVE_USERS[@]}; do
    while IFS="," read -r uid lastLoginDate
    do
        sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:disable $uid
        echo "$uid is locked"
        echo "$uid,$lastLoginDate" >> $_DIR/reports/users_disabled-$TODAY.csv
        echo ""
    done < <(tail -n +2 $FILE_INACTIVE_USERS)
done

echo ""
echo "It's done !"
echo "All CSV files of users inactives are disabled."
