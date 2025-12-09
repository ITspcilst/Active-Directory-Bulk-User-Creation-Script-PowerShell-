<#
.SYNOPSIS
    Bulk Active Directory User Creation Script with Logging, CSV input,
    error handling, and per-user configuration.

.DESCRIPTION
    This script reads users from a CSV file and creates them in AD.
    It supports:
      - OU per user
      - Group(s) per user
      - Random secure passwords
      - Logging of successes & failures
      - Idempotent checks (skip existing users)

#>

Import-Module ActiveDirectory

# --- CONFIGURATION ---
$CSVPath = ".\Input\users.csv"
$LogFile = ".\Logs\creation-log.txt"

# --- START LOG ---
"=== Bulk AD Creation Run: $(Get-Date) ===" | Out-File $LogFile -Append

# --- FUNCTION: Write Log ---
function Write-Log($Message) {
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File $LogFile -Append
}

# --- FUNCTION: Generate Random Password ---
function New-RandomPassword {
    Add-Type -AssemblyName System.Web
    return [System.Web.Security.Membership]::GeneratePassword(12,2)
}

# --- IMPORT CSV ---
try {
    $Users = Import-Csv $CSVPath
    Write-Log "Loaded $($Users.Count) users from CSV."
}
catch {
    Write-Log "ERROR: Failed to read CSV: $_"
    Write-Host "Failed to read CSV." -ForegroundColor Red
    exit
}

foreach ($User in $Users) {

    $Sam = $User.SamAccountName
    $OU  = $User.OU
    $Groups = $User.Groups -split ";"
    $Password = New-RandomPassword

    # Skip existing accounts
    if (Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue) {
        Write-Log "SKIPPED: $Sam already exists."
        continue
    }

    try {
        New-ADUser `
            -SamAccountName $Sam `
            -UserPrincipalName "$Sam@$($User.Domain)" `
            -Name $User.DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -Department $User.Department `
            -Title $User.Title `
            -OfficePhone $User.Phone `
            -Path $OU `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Log "CREATED: $Sam successfully."

        # Add to groups
        foreach ($Group in $Groups) {
            try {
                Add-ADGroupMember -Identity $Group -Members $Sam
                Write-Log "  Added $Sam to group: $Group"
            }
            catch {
                Write-Log ("  ERROR adding {0} to {1}: {2}" -f $Sam, $Group, $_)

            }
        }
    }
    catch {
        Write-Log ("ERROR creating {0}: {1}" -f $Sam, $_)

    }
}

Write-Log "=== Script Finished ==="
Write-Host "Bulk AD creation finished. Check log for details."