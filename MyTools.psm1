<#
Powershell Module
Requires Powershell Version 3.0

Name: MyTools
Location: C:\Users\sysdjm\Documents\WindowsPowerShell\Modules\MyTools\MyTools.psm1
Contains:
        Add-F5Group
        Create-Password
        Edit-HostsFile
        Get-ADUserInfo
        Get-ADUserPasswordExpirationDate
        Get-ADUserSkypeInfo
        Get-Excuse
#>

function Get-ADUserInfo() {

<#
  .SYNOPSIS
  Retrieves ADUser information.  Returns more infor than default.
  .DESCRIPTION
  Just a Get-ADUser call with specific properties being returned.  Properties returned inlcude:
    •Name
    •SamAccountName
    •DistinguishedName
    •Department
    •Title
    •EmailAddress
    •AccountLockoutTime
    •LockedOut
    •LockoutTime
    •BadLogonCount
    •badPwdCount
    •PasswordExpired
    •PasswordLastSet
    •PasswordNeverExpires
    •LastBadPasswordAttempt
    •LastLogonDate
    •WhenChanged
  .EXAMPLE
  Get-ADUserSkypeInfo -UserAccount jdoe
  .EXAMPLE
  Get-ADUserSkypeInfo jdoe -server ADServer01
  .PARAMETER UserAccount
  The username to query. Just one.
  .PARAMETER Server
  Name of the server to query Get-ADUser from (optional)
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True,ValueFromPipeline=$True,HelpMessage='What user account would you like to query"')]$UserAccount,
    [parameter(Mandatory=$False,HelpMessage='Would you like to query a specific server?')]$Server
)

Begin
    {
    Write-Host "`nActive directory user information" -ForegroundColor Yellow
    }

Process
    {
    get-aduser $UserAccount -properties AccountLockoutTime,BadLogonCount,badPwdCount,CannotChangePassword,Department,EmailAddress,LastBadPasswordAttempt,LastLogonDate,LockedOut,lockoutTime,Modified,PasswordExpired,PasswordLastSet,PasswordNeverExpires,PasswordLastSet,SamAccountName,Title,WhenChanged,WhenCreated `
    | fl Name,SamAccountName,DistinguishedName,Department,Title,EmailAddress,AccountLockoutTime,LockedOut,LockoutTime,BadLogonCount,badPwdCount,PasswordExpired,PasswordLastSet,passwordNeverExpires,LastBadPasswordAttempt,LastLogonDate,WhenChanged
    }
 }

function Get-ADUserSkypeInfo() {

<#
  .SYNOPSIS
  Retrieves ADUser information and includes Skype related properties.
  .DESCRIPTION
  Just a Get-ADUser call with specific properties being returned
  .EXAMPLE
  Get-ADUserSkypeInfo -UserAccount jdoe
  .EXAMPLE
  Get-ADUserSkypeInfo jdoe -server ADServer01
  .PARAMETER UserAccount
  The username to query. Just one.
  .PARAMETER Server
  Name of the server to query Get-ADUser from (optional)
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True,ValueFromPipeline=$True,HelpMessage='What user account would you like to query"')]$UserAccount,
    [parameter(Mandatory=$False,HelpMessage='Would you like to query a specific server?')]$Server
)

Begin 
    {
    Write-Host "`nQuerying active directory for user information" -ForegroundColor Yellow
    }

Process
    {
    get-aduser $UserAccount -properties department,EmailAddress,Title,msRTCSIP-DeploymentLocator,msRTCSIP-FederationEnabled,msRTCSIP-InternetAccessEnabled,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,msRTCSIP-PrimaryUserAddress,msRTCSIP-UserEnabled,msRTCSIP-UserPolicies,msRTCSIP-UserRoutingGroupId `
    | fl Name,SamAccountName,DistinguishedName,Department,Title,EmailAddress,msRTCSIP-DeploymentLocator,msRTCSIP-FederationEnabled,msRTCSIP-InternetAccessEnabled,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,msRTCSIP-PrimaryUserAddress,msRTCSIP-UserEnabled,msRTCSIP-UserPolicies,msRTCSIP-UserRoutingGroupId
    }
}

function Create-Password() {
<#
.SYNOPSIS
  Create a random password of specified length.
.DESCRIPTION
  Using specified character set, a random password is generated to follow ADM Password Policy guidelines
.EXAMPLE
  Get-ADUserSkypeInfo -UserAccount jdoe
.EXAMPLE
  Get-ADUserSkypeInfo jdoe -server ADServer01
.PARAMETER UserAccount
  The username to query. Just one.
.PARAMETER Server
  Name of the server to query Get-ADUser from (optional)
#>

[CmdletBinding()]
Param (
 [parameter(Mandatory=$True,HelpMessage='Password length?"')]$Length
)

# Removed lowercase L, uppercase I, uppercase O, and 0 (zero) to eliminate confusion of password creation
   $specialCharacters = "!@#$%^&*()"
   $lowerCase = "abcdefghijkmnopqrstuvwxyz"
   $upperCase = "ABCDEFGHJKLMNPQRSTUVWXYZ"
   $numbers = "123456789"
   $res = ""
   $rnd = New-Object System.Random

do
   {
       $flag = $rnd.Next(4);
       if ($flag -eq 0)
       {$res += $specialCharacters[$rnd.Next($specialCharacters.Length)];
       } elseif ($flag -eq 1)
       {$res += $lowerCase[$rnd.Next($lowerCase.Length)];
       } elseif ($flag -eq 2)
       {$res += $upperCase[$rnd.Next($upperCase.Length)];
       } else
       {$res += $numbers[$rnd.Next($numbers.Length)];
       }
   } while (0 -lt $Length--)
   return $res
}

function Add-F5Group() {
<#
.SYNOPSIS
    Create a new AD security group for use in the F5 SSL VPN

.DESCRIPTION
    Creates a new AD group in the APPS OU based on input parameters

.PARAMETER
    -GoupName [<String>]
        Specify the group name.
        Example: GrpF5_NewGroupName
    
    -Description [<String>]
        Specify the description of the group.
        Example: "RaSSLVPN - External access to StoreSupport.RiteAid.com"
    
.EXAMPLE
    Add-F5Group -GroupName GrpF5_NewGroupName -Description "RaSSLVPN - External access to StoreSupport.RiteAid.com"

.NOTES

Name:   Add-F5Group
Author: Dan Machovec
Verson: 1.0 Initial Version

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,Position=1)][String]$GroupName,
    [Parameter(Mandatory=$true,Position=2)][String]$Description
    
)

BEGIN {
    
    #Initialise Global Variables
    $Scope = "Global"                                     # Options: DomainLocal,Global,Universal
    $Category = "Security"                                # Options: Distribution,Security
    $Path = "ou=SSLVPN,ou=Apps,dc=ra,dc=riteaid,dc=us"
}

PROCESS
    {
    New-ADGroup -Name $GroupName -GroupScope $Scope -GroupCategory $Category -path $Path -Description $Description -DisplayName $GroupName -SamAccountName $GroupName
}

END{}
}

function Edit-HostsFile {
<#
.SYNOPSIS
    Starts Notepad.exe as administrator and opens C:\Windows\System32\Drivers\Etc\Hosts for editing
.EXAMPLE
    Edit-Hostsfile

Name:    Edit-Hostsfile
Author:  Dan Machovec
Version: v1.0 Initial Version
#>

[CmdletBinding()]
param()
BEGIN
{}
PROCESS
{Start-Process -FilePath notepad -ArgumentList "$env:windir\system32\drivers\etc\hosts"}
END {}
}

function Get-ADUserPassowrdExpirationDate() {
<#
.SYNOPSIS
    Get account password expiration
.DESCRIPTION
    
.PARAMETER
    -Identity [<String>]
.EXAMPLE
    Get-ADUserPasswordExpirationDate -Identity sysdjm

Name:    Get-ADUserPassowrdExpirationDate
Author:  Dan Machovec
Version: v1.0 Initial Version
#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage='Account you want to check password expiration for?')]
    [PSObject]$Identity
)
BEGIN
{}
PROCESS
{
    $accountObj = Get-ADUser $Identity -properties PasswordExpired, PasswordNeverExpires, PasswordLastSet
    if ($accountObj.PasswordExpired) {
        echo ("Password of account: " + $accountObj.Name + " already expired!")
    } else { 
    
        if ($accountObj.PasswordNeverExpires) {
            echo ("Password of account: " + $accountObj.Name + " is set to never expires!")
        } else {
            $passwordSetDate = $accountObj.PasswordLastSet
    
    if ($passwordSetDate -eq $null) {
        echo ("Password of account: " + $accountObj.Name + " has never been set!")
    }  else {
        $maxPasswordAgeTimeSpan = $null
        $dfl = (get-addomain).DomainMode
    
    if ($dfl -ge 3) { 
    ## Greater than Windows2008 domain functional level
        $accountFGPP = Get-ADUserResultantPasswordPolicy $accountObj
    
    if ($accountFGPP -ne $null) {
    $maxPasswordAgeTimeSpan = $accountFGPP.MaxPasswordAge
    } else {
    
    $maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
    }
    
    } else {
    $maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
    }
    
    if ($maxPasswordAgeTimeSpan -eq $null -or $maxPasswordAgeTimeSpan.TotalMilliseconds -eq 0) {
        echo ("MaxPasswordAge is not set for the domain or is set to zero!")
    } else {
        echo ("Password of account: " + $accountObj.Name + " expires on: " + ($passwordSetDate + $maxPasswordAgeTimeSpan))
    }}}}}
END {}
}

function Get-Excuse {
    Get-Random (iwr http://pages.cs.wisc.edu/~ballard/bofh/excuses).Content.Split([Environment]::NewLine)
    }
