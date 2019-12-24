#!/bin/bash

# remember to add the following to /etc/crontab to run this every 5 minutes
# */5 * * * * ec2-user /home/ec2-user/mark/website-checker/ripplestone-checker.sh

# check cron execution logs (not output of the commands) at
# sudo tail -30 /var/log/cron

# check user mail, which shows the resulting output of the commands from cron
# sudo tail -30 /var/mail/root

DATEANDTIME=$(date +%F" "%r" "%A)
RIPPLEHOST=172.31.46.121

UPMESSAGE=$"Ripplestone is up."
SERVERUNAVAILABLE=$"Server is unavailable over SSH. Check the server."
RIPPLEDOWN=$"Ripplestone is down."
RIPPLERESTARTED=$"Ripplestone was restarted."
RIPPLENOTRESTARTED=$"Ripplestone was NOT restarted. Check the service."

echo $DATEANDTIME | tee -a /home/centos/website-checker/log
echo "" | tee -a log

nc -z $RIPPLEHOST 22
if [[ $? -eq 0 ]]
then
  echo "Ripplestone server is reachable on SSH." | tee -a /home/centos/website-checker/log
  echo "" | tee -a /home/centos/website-checker/log
else
  echo "Ripplestone server is unreachable on SSH. Check status of server." | tee -a /home/centos/website-checker/log
  aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$SERVERUNAVAILABLE" | tee -a /home/centos/website-checker/log
  echo "" | tee -a /home/centos/website-checker/log
  echo "--------------------------------------" | tee -a /home/centos/website-checker/log
  exit 1
fi

# google.com generates a 301 error code. www.google.com generates a 200 ok code
curl -I "google.com" | tee /home/centos/website-checker/curl-result 1> /dev/null

if grep -q "HTTP/1.1 200" /home/centos/website-checker/curl-result
then
  echo $UPMESSAGE | tee -a /home/centos/website-checker/log
  exit 0
else
  echo $RIPPLEDOWN | tee -a /home/centos/website-checker/log
  ssh mnouri@$RIPPLEHOST 'C:\Scripts\restart-ripplestone.bat' | tee -a /home/centos/website-checker/log | tee /home/centos/website-checker/bat-script-output
fi

if grep -q "The Print Spooler service was started successfully." /home/centos/website-checker/bat-script-output
then
  echo $RIPPLERESTARTED | tee -a /home/centos/website-checker/log
  aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$RIPPLERESTARTED" | tee -a /home/centos/website-checker/log
  echo "--------------------------------------" | tee -a /home/centos/website-checker/log
  exit 0
else
  echo $RIPPLENOTRESTARTED | tee -a /home/centos/website-checker/log
  aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$RIPPLENOTRESTARTED" | tee -a /home/centos/website-checker/log
  echo "--------------------------------------" | tee -a /home/centos/website-checker/log
  exit 1
fi

