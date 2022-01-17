# 🎯 Introduction

It's a tool to manage users for Nextcloud.

With this tool you can disable and delete users who are'nt connect from X days.

# 🔨 How to work ?

First, you should copy `config-sample.sh` to `config.sh` and the fill it.

```bash
#!/bin/bash
PATH_NEXTCLOUD=""
USER_WEB=""
NUMBER_DAYS_TO_CHECK=""
```

- `PATH_NEXTCLOUD` : It's the absolute path of your Nextcloud. For example : `/var/www/html/nextcloud/my-nextcloud.fr`.
- `USER_WEB` : It's your user web of your webserver. We have `www-data` for apache and `nginx` for nginx.
- `NUMBER_DAYS_TO_CHECK` : It's the number of days to check the last login of your users. For example : If you want check the users who aren't connect from 1 months. You should define `30` for 30 days.

For example to fill the `config.sh` :

```bash
#!/bin/bash
PATH_NEXTCLOUD="/var/www/html/nextcloud/my-nextcloud.fr"
USER_WEB="nginx"
NUMBER_DAYS_TO_CHECK="60"
```

Here, I define the path of my nextcloud instance, the user web of my webserver is **nginx** and I would like check the users who aren't connect from 2 months in writting **60**.

Then, you should these command in the order :

1. `bash ./main.sh` 👉 To create a csv file of users who are inactives
2. `bash ./disable-users.sh <path-to-users-disabled-csv>` 👉 To disable users with the `users_inactive-YYYYMMDD.HHmm.csv` file as argument
3. `bash ./deleting-disabled-users.sh <path-to-users-disabled-csv>`  👉 To delete users with the `users_disabled-YYYYMMDD.HHmm.csv` file as argument

When you execute the `main.sh` script, it creates a `reports` folder and it contains all csv files. It will create a csv file like this : `users_inactive-20220117.1217.csv` where it contains all users who are inactives from X days.
With the `disable-users.sh` script, it will create a csv file like this `users_disabled-20220117.1218.csv` where it contains all users who will be disabled.