$dateandtime = Get-Date
$upmessage = "Ripplestone is up. (Message from Ripplestone server.)"
$downmessage = "Ripplestone was down and was reset. Confirm it is up now. (Message from Ripplestone server.)"

Invoke-WebRequest -URI "http://ripplestone.coreebusiness.com/ripplestone/CRViewer.aspx?DocID=3796&User=Administrator&Key=ae1bcdf5" > curl-result.txt

if (Select-String -Path curl-result.txt -Pattern "HTTP/1.1 200 OK") {
    Write-Host $upmessage
    echo $dateandtime $upmessage >> log.txt
    }
    Else {
    Write-Host $downmessage
    echo $dateandtime $downmessage >> log.txt
    aws sns publish --topic-arn arn:aws:sns:us-east-1:266721470201:Mark --message $downmessage
    # aws sns publish --topic-arn arn:aws:sns:us-east-1:266721470201:CloudWatchToSlack --message $downmessage
    aws sns publish --topic-arn arn:aws:sns:us-east-1:266721470201:Jorge-Email --message $downmessage
    aws sns publish --topic-arn arn:aws:sns:us-east-1:266721470201:Skiye-Email --message $downmessage
    # aws sns publish --topic-arn arn:aws:sns:us-east-1:266721470201:Howard-Mobile-SMS --message $downmessage
    # aws sns publish --topic-arn arn:aws:sns:us-east-1:266721470201:TJ-Email --message $downmessage
    C:\Scripts\RestartIIS.bat
}