#!/usr/bin/env bash
# Write out current crontab
crontab -l > cron_file
# Echo new cron into cron file
echo "*/5 08-18 * * 1-5 $FIYELI_CORE_ROUTINE" >> cron_file
        # Install new cron file
        crontab cron_file
        rm cron_file
