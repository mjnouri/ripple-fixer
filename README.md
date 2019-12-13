Bash script that checks if a web based reporting system is up. If it is down, the script will write the date, time, and a 'down' message, alert an engineer via AWS SNS, and SSH to the Windows reporting server via OpenSSH and run a script to repair services while writing everything to a log file.

Future plans - Check to see if the Windows service was actually restarted for confirmation.

See the run-windows-commands-remotely-from-linux-with-openssh repo for a guide on how to set up, configure, and execute Windows commands or scripts remotely from a Linux box.
