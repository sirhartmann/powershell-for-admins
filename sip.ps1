#========================================================================
# Created on:   25.04.2016
# Created by:   sirhartmann
# Filename:     sip.ps1
#
# Description:  Add SIP address to Exchange 
#				mailbox based on PrimarySmtpAddress
#========================================================================
 
#Load Defaults
set-adserversettings -viewentireforest $true
 
#Get all mailboxes filtered by RecipientTypeDetails "UserMailbox" and CustomAttribute4 "Employee"
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox -filter {CustomAttribute4 -eq 'Employee'}
 
#add SIP address to all mailboxes
foreach ($mailbox in $mailboxes) {
#check if SIP address is already set
if ( ($mailbox.emailaddresses | % { $_.prefixstring }) -notcontains 'SIP' )
{
                #email address construct based on primary smtp address
                $seperator = "@"
                $smtp = $mailbox.PrimarySmtpAddress
                $tosplit = $smtp.ToString()
                $splited = $tosplit.split($seperator)
                write-host $splited[0] -foregroundcolor "green"
                $sipaddress = $splited[0]
               
                #set SIP address with standard @mydomain.com domain --> remove "-whatif"
                Set-Mailbox -Identity $mailbox -EmailAddresses (($mailbox.emailaddresses) +="SIP:$($sipaddress)@mydomain.com")  -whatif
}
else { write-host "SIP Address found on $($mailbox.PrimarySmtpAddress), Skipped" -foregroundcolor "magenta" }
}
