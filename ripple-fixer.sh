#!/bin/bash

# add the following to /etc/crontab to run this every 5 minutes
# */5 * * * * ec2-user /home/ec2-user/ripple-fixer/ripple-fixer.sh

# check cron execution logs (not output of the commands) at
# sudo tail -30 /var/log/cron

# check user mail, which shows the resulting output of the commands from cron
# sudo tail -30 /var/mail/root

DATE_AND_TIME=$(date +%F" "%r" "%A)
RIPPLE_HOST=172.31.105.232

RIPPLE_UP=$"Ripplestone is up."
RIPPLE_DOWN=$"Ripplestone is down."
SERVER_SSH_UP=$"Ripplestone server is reachable on SSH."
SERVER_SSH_DOWN=$"Server is unavailable over SSH. Check the server."
RIPPLE_RESTARTED=$"Ripplestone was restarted."
RIPPLE_NOT_RESTARTED=$"Ripplestone was NOT restarted. Server is up, but check the service."

nc -z $RIPPLE_HOST 22
if [[ $? -eq 0 ]]
then
  echo $SERVER_SSH_UP
else
  echo $DATE_AND_TIME >> /home/ec2-user/ripple-fixer/log
  echo $SERVER_SSH_DOWN >> /home/ec2-user/ripple-fixer/log
  aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$SERVER_SSH_DOWN" >> /home/ec2-user/ripple-fixer/log
  echo "--------------------------------------" >> /home/ec2-user/ripple-fixer/log
  exit 1
fi

curl -I "www.google.com" | tee /home/ec2-user/ripple-fixer/curl-result 1> /dev/null

if grep -q "HTTP/1.1 200" /home/ec2-user/ripple-fixer/curl-result
then
  echo $RIPPLE_UP
  exit 0
else
  echo $DATE_AND_TIME >> /home/ec2-user/ripple-fixer/log
  echo $RIPPLE_DOWN >> /home/ec2-user/ripple-fixer/log
  ssh windowsUser@$RIPPLE_HOST 'C:\Scripts\restart-ripple-service.bat' | tee -a /home/ec2-user/ripple-fixer/log | tee /home/ec2-user/ripple-fixer/bat-script-output
fi

if grep -q "service was started successfully" /home/ec2-user/ripple-fixer/bat-script-output
then
  echo $RIPPLE_RESTARTED >> /home/ec2-user/ripple-fixer/log
  aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$RIPPLE_RESTARTED" >> /home/ec2-user/ripple-fixer/log
  echo "--------------------------------------" >> /home/ec2-user/ripple-fixer/log
  exit 0
else
  echo $RIPPLE_NOT_RESTARTED >> /home/ec2-user/ripple-fixer/log
  aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$RIPPLE_NOT_RESTARTED" >> /home/ec2-user/ripple-fixer/log
  echo "--------------------------------------" >> /home/ec2-user/ripple-fixer/log
  exit 1
fi