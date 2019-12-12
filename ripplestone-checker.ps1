# This PowerShell script checks if the reporting system is up.
# If the system is crashed, write it to the log file, notify users via SNS, and fix the crash.

# Add this to Task Scheduler

# Give EC2 SNS permissions

$dateandtime = Get-Date
$upmessage = "Ripplestone is up. (Message from Ripplestone server.)"
$downmessage = "Ripplestone was down and was reset. Confirm it is up now. (Message from Ripplestone server.)"

Invoke-WebRequest -URI "https://www.google.com" > curl-result.txt

if (Select-String -Path curl-result.txt -Pattern "HTTP/1.1 200 OK") {
    Write-Host $upmessage
    echo $dateandtime $upmessage >> log.txt
    }
    Else {
    Write-Host $downmessage
    echo $dateandtime $downmessage >> log.txt
    aws sns publish --topic-arn arn:aws:sns:us-east-1:123:Me --message $downmessage
    powershell -command "Start-Process RestartIIS-RunAsAdmin.bat -Verb runas"
}