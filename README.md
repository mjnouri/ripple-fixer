Overview - Bash script that checks if a web based reporting service is running. If it is not running, it restarts the service.

Script - The script first attempts to reach the reporting server. If it is not available, the script exits with an AWS SNS notification. If the server is available, the scripts curls the reporting web page. If 200 is found, the script exits and the reporting system is up. If no 200 is found, it passwordless SSHs to the reporting server and restarts the service. If the service was or was not successfully restarted, the script exits with an appropriate SNS notification.

See the ssh-to-windows repo for a guide on how to set up, configure, and execute Windows commands or scripts remotely from a Linux box.

For this test environment's sake, I am curling google.com to generate a 301 error code, www.google.com to generate a 200 ok code, and restarting the Print Spooler service instead of installing the reporting service on the test server.
