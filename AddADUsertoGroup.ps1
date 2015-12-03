# A simple script to add an AD user to an AD group
# Both the user and the group must already exist

# Import the Active Directory module
Import-Module ActiveDirectory

# Set variables for checking the existance of specified AD user and group
$UserExists = $null
$GroupExists = $null

# Request user account input for AD user account

#Do loop will request user account name and check to see if it exists.  You cannot continue until you enter a existing AD account
Do  {

    # Write out request for input
    Write-Host "`r`n Please enter the user account to add to an AD security group: " -ForegroundColor Yellow -NoNewline
    $ADUser = Read-Host 
    
    # Checks AD user account against AD using SAM Account Name
    $UserExists = Get-ADUser -Filter {SamAccountName -eq $ADUser}
    
    # Since variable was set as $null above, if the account is found in AD the variable will have the Sam Account Name as a value, and not be null
    If ($UserExists -eq $null)
        { Write-Host "User does not exist in AD.  Please try again." }
        Else 
        { Write-Host "User found" }
    
    }

Until ($UserExists -ne $null)

#Do loop will request group account name and check to see if it exists.  You cannot continue until you enter a existing AD group
Do 	{

    # Write out request for input
    Write-Host "`r`n Please enter the group name to add to: " -ForegroundColor Cyan -NoNewline
    $ADGroup = Read-Host 

    # Checks AD user account against AD using SAM Account Name
    $GroupExists = Get-ADgroup -Filter {SamAccountName -eq $ADGroup}

    If ($GroupExists -eq $null)
        { Write-Host "Group does not exist in AD.  Please try again." }
        Else 
        { Write-Host "Group found" }

	}

Until ($GroupExists -ne $null)

Write-Host -ForegroundColor Red -BackgroundColor Black "`r`n`r`n**** Are you sure you want to add $ADUser to $ADGroup ? ****"
Write-Host -ForegroundColor Yellow "`r`nPress " -NoNewline
Write-Host -ForegroundColor White "Y " -NoNewline
Write-Host -ForegroundColor Yellow "to continue. " -NoNewline
Write-Host -ForegroundColor White "Any other key " -NoNewline
Write-Host -ForegroundColor Yellow "to cancel."

$Selection = (Read-Host "`r`nSelection: ")
    
If (($Selection -eq "Y") -or ($Selection -eq "y"))
    {

    # Display the outcome of the above steps
    Write-Host -ForegroundColor Yellow "`r`n $ADUser" -NoNewLine
    Write-Host -ForegroundColor White " added to " -NoNewLine
    Write-Host -ForegroundColor Cyan "$ADGroup"

    # Add specified user to specified group
    #Add-ADGroupMember -Identity $ADGroup -Members $ADUser
    }
    
    Else {Write-Host -ForegroundColor Red -BackgroundColor Black "`r`nCanceled by user"}
