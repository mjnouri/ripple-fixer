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


curl -I "www.google.com" > /home/ec2-user/mark/website-checker/curl-result


if grep -q 200 /home/ec2-user/mark/website-checker/curl-result
then
 echo $UPMESSAGE
 echo "$DATEANDTIME - $UPMESSAGE" >> /home/ec2-user/mark/website-checker/log
 echo "-------------------------" >> /home/ec2-user/mark/website-checker/log
else
 echo $DOWNMESSAGE
 echo "$DATEANDTIME - $DOWNMESSAGE" >> /home/ec2-user/mark/website-checker/log
 aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message "$DOWNMESSAGE"
 ssh windowsUser@172.31.104.231 'C:\Scripts\RestartIIS-RunAsAdmin.bat' >> /home/ec2-user/mark/website-checker/log
 echo "-------------------------" >> /home/ec2-user/mark/website-checker/log
fi
