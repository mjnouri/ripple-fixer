#!/bin/bash

# Amazon Linux 2

# remember to add the following to /etc/crontab to run this every 5 minutes
# */5 * * * * ec2-user /home/ec2-user/mark/website-checker/ripplestone-checker.sh

# check cron execution logs (not output of the commands) at
# sudo tail -30 /var/log/cron

# check user mail, which shows the resulting output of the commands from cron
# sudo tail -30 /var/mail/root

# Give EC2 SNS permission


DATEANDTIME=$(date +%F" "%r" "%A)
UPMESSAGE=$"Ripplestone is up."
DOWNMESSAGE=$"Ripplestone is down."

curl -I "https://www.google.com" > curl-result

if grep -q 200 curl-result
then
 echo $UPMESSAGE
 echo "$DATEANDTIME - $UPMESSAGE" >> log
else
 echo $DOWNMESSAGE
 echo "$DATEANDTIME - $DOWNMESSAGE" >> log
 aws sns publish --topic-arn arn:aws:sns:us-east-1:123456:Me --message "$DOWNMESSAGE"
fi
