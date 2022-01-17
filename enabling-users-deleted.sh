#!/bin/bash

if [ -z "$1" ]; then
    echo "No argument."
    echo "You should define the absolute path of your CSV file."
    echo "For example : bash ./enabling-users-deleted.sh /home/foobar/projets/account-log-in/reports/users_disabled-20220117.1102.csv"
    exit
fi

source config.sh

_DIR=$(pwd)

if [[ ! -d $_DIR/reports ]]; then
    echo "reports dir is not exists"
    exit 1
fi

FILE_DISABLED_USERS=$1
DATE_LIMIT=$(date -d "-$NUMBER_DAYS_TO_CHECK days" +%s)

# Disabled users who aren't log in from than 3 month (30 days).
# read file
# Source: https://www.baeldung.com/linux/csv-parsing#1-from-all-columns
for FILE_DISABLED_USERS in ${FILE_DISABLED_USERS[@]}; do
    while IFS="," read -r uid lastLoginDate
    do
        sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:enable $uid
        echo "$uid is enabled"
        echo ""
    done < <(tail -n +2 $FILE_DISABLED_USERS)
done

echo ""
echo "It's done !"
echo "All CSV files of users inactives are enabled."
