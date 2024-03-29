﻿$ADUSERS=Import-csv C:\Users\Administrator.WIN11-DC1\Downloads\intranet.mijnschool.be\UserAccounts.csv -Delimiter ';'

foreach($account in $ADUSERS){
#fill variables
$name=$account.Name
$DispName=$account.DisplayName
$surName=$account.Surname
$path=$account.Path
$samAccountN=$account.SamAccountName
$givenName=$account.GivenName
$homedir=$account.HomeDirectory
$scriptpath=$account.ScriptPath
$accPass=$account.AccountPassword
$driveLetter=$account.HomeDrive

# Create users
New-ADUser -Name $name `
-DisplayName $DispName `
-Surname $surName `
-Path $path `
-SamAccountName $samAccountN `
-GivenName $givenName `
-PasswordNeverExpires $True `
-ScriptPath $scriptpath `
-Enabled $true `
-AccountPassword (ConvertTo-SecureString $accPass -AsPlainText -Force) `
-ChangePasswordAtLogon $false


#Make home dirs --nog aanpassen--
$fullPath = "\\win11-MS\homes\{0}" -f $samAccountN
 
$User = Get-ADUser -Identity $samAccountN
 
if($User -ne $Null) {
    Set-ADUser $User -HomeDrive $driveLetter -HomeDirectory $fullPath -ea Stop
    $homeShare = New-Item -path $fullPath -ItemType Directory -force -ea Stop
 
    $acl = Get-Acl $homeShare
 
    $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Fullcontrol"
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"
 
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User.SID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    $acl.AddAccessRule($AccessRule)
 
    Set-Acl -Path $homeShare -AclObject $acl -ea Stop
 
    Write-Host ("HomeDirectory created at {0}" -f $fullPath)
}
}