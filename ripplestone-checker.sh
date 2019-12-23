#!/bin/bash

# remember to add the following to /etc/crontab to run this every 5 minutes
# */5 * * * * ec2-user /home/ec2-user/mark/website-checker/ripplestone-checker.sh

# check cron execution logs (not output of the commands) at
# sudo tail -30 /var/log/cron

# check user mail, which shows the resulting output of the commands from cron
# sudo tail -30 /var/mail/root

DATEANDTIME=$(date +%F" "%r" "%A)
UPMESSAGE=$"Ripplestone is up."
DOWNMESSAGE=$"Ripplestone was down and was reset."
RIPPLEHOST=172.31.46.121

echo $DATEANDTIME | tee -a /home/centos/website-checker/log
echo "" | tee -a log

nc -z $RIPPLEHOST 22
if [[ $? -eq 0 ]]
then
  echo "Ripplestone server is reachable on SSH." | tee -a /home/centos/website-checker/log
else
  echo "Ripplestone server is unreachable on SSH. Check status of server." | tee -a /home/centos/website-checker/log
  echo "" | tee -a /home/centos/website-checker/log
  echo "--------------------------------------" | tee -a /home/centos/website-checker/log
  exit 1
fi

curl -I "www.google.com" | tee /home/centos/website-checker/curl-result

if grep -q 200 /home/centos/website-checker/curl-result
then
 echo $UPMESSAGE
 echo $UPMESSAGE | tee -a /home/centos/website-checker/log
else
 echo $DOWNMESSAGE
 echo $DOWNMESSAGE | tee -a /home/centos/website-checker/log
 aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$DOWNMESSAGE" | tee -a /home/centos/website-checker/log
 ssh windowsUser@$RIPPLEHOST 'C:\Scripts\restart-spooler.bat' | tee -a /home/centos/website-checker/log | tee /home/centos/website-checker/output
 echo "----------------------------------------------" | tee -a /home/centos/website-checker/log
fi

if grep -q "The Print Spooler service was started successfully." /home/centos/website-checker/curl-result
then
 echo "Message from script - Print Spooler was restarted" | tee -a /home/centos/website-checker/log
else
 echo "Message from script - Print Spooler was not restarted. Check the server" | tee -a /home/centos/website-checker/log
fi

