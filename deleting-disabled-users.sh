#!/bin/bash

if [ -z "$1" ]; then
    echo "No argument."
    echo "You should define the absolute path of your CSV file."
    echo "For example : bash ./deleting-disabled-users.sh /home/foobar/projets/account-log-in/reports/users_disabled-20220117.1102.csv"
    exit
fi

source config.sh

_DIR=$(pwd)

if [[ ! -d $_DIR/reports ]]; then
    echo "reports dir is not exists"
    exit 1
fi

FILES_DISABLED_USERS=$1

# Build disabled csv file
TODAY=$(date "+%Y%m%d.%H%M")
echo "uid,last-login-date" >> $_DIR/reports/users_deleted-$TODAY.csv

# read file
# Source: https://www.baeldung.com/linux/csv-parsing#1-from-all-columns
for FILE_DISABLED_USERS in ${FILES_DISABLED_USERS[@]}; do
    echo $FILE_DISABLED_USERS
    while IFS="," read -r uid lastLoginDate
    do
        echo "- UID: $uid"
        typeConnection=$(sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:info $uid | grep -i backend | awk -F ":" '{print $2}')
        if [ $typeConnection = "LDAP" ]; then 
            echo "It's a LDAP user"
            sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:setting $uid user_ldap isDeleted 1
            sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:delete $uid
        else
            echo "It's a DATABASE user"
            sudo -u $USER_WEB php $PATH_NEXTCLOUD/occ user:delete $uid
        fi
        echo "$uid is deleted"
        echo "$uid, $lastLoginDate >> $_DIR/reports/users_deleted-$TODAY.csv"
    done < <(tail -n +2 $FILE_DISABLED_USERS)
done


echo ""
echo "It's done !"
echo "All users are deleted from the $1 CSV file."
