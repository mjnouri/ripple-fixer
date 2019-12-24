Bash script that checks if a web based reporting server is available. If it is not available, the script exits with an AWS SNS notification. If the server is available, the scripts curls the reporting web page. If no 200 is found, it SSHes to the reporting server and restarts the service. If the service was or was not successfully restarted, the script exits with an appropriate SNS notification.

See the ssh-to-windows repo for a guide on how to set up, configure, and execute Windows commands or scripts remotely from a Linux box.
