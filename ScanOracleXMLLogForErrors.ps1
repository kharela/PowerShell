# Scan for Oracle errors in alert\log.xml file.
$HoursToGoBack=14
$ErrMatchPattern="ORA-00600|drift|start"
#
# We assume that each XML MSG node contains a TIME sub node
#    with timestamp in the following format
# $timestampPattern='^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d'
# 
$startTSPattern=((Get-Date).AddHours(-$HoursToGoBack)).ToString('yyyy-MM-ddTHH:00:00')
#$startTSPattern='2023-07-13T06:00:00'
$logFile='C:\oracle\product\18.0.0\diag\rdbms\xe\xe\alert\log.xml'
#
# Oracle log.xml is not a properly formed XML document since it is a collection of <MSG> nodes with no parent node.
# Setup XML loading by creating a shell XML document containing top level Messages node.
[xml]$XMLLog='<Messages/>'
# Load the content of log.xml into xmldoc under node messages
$XMLLog.FirstChild.InnerXml = Get-Content $logfile

# Filter MSG with time -GE startingTSPattern
$RelevantMsgs= $XMLLog.Messages.msg | where time -ge $startTSPattern

# Filter again to caputure only those messages that match error pattern.
$MsgsWError=$RelevantMsgs | where txt -Match $ErrMatchPattern

$attachmentFile='c:\temp\ora_errors.txt'

if ($MsgsWError -ne $null -and $MsgsWError -ne '') {
    # dump the matching errors into a holding file.
    "Errors written to $attachmentFile"
    "Errors detectected since '$startTSPattern'" | Out-File $attachmentFile -Force
    # $MsgsWError | ConvertTo-Xml -as String |Out-File $attachmentFile -Force
     $MsgsWError | Out-File $attachmentFile -Force
    # $attachmentFile contains any errors captured.
    # adjust the following line to get email sent with error list attached.
    #Send-MailMessage -To RecipientEmail -From senderEmail -Subject 'Oracle Errors detected' -Body 'See Attachment' -SmtpServer companyEmailServer -Attachments c:\temp\ora_errors.log

    }


