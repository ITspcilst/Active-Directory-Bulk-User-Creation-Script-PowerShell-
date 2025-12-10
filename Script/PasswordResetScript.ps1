Import-Module ActiveDirectory

# ================================
# Path Configuration
# ================================
$CSVPath    = ".\Input\users.csv"          # The user list you already have
$OutputPath = ".\Passwords"                # Folder to store the password CSV
$OutputCSV  = "$OutputPath\passwords.csv"  # Password export file

# ================================
# Create Passwords Folder If Missing
# ================================
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# ================================
# Prepare Collection For Export
# ================================
$PasswordResults = @()

# ================================
# Password Generator Function
# ================================
function New-RandomPassword {
    Add-Type -AssemblyName System.Web
    return [System.Web.Security.Membership]::GeneratePassword(12,2)
}

# ================================
# Import CSV User List
# ================================
try {
    $Users = Import-Csv $CSVPath
    Write-Host "Loaded $($Users.Count) users from CSV." -ForegroundColor Yellow
}
catch {
    Write-Host "ERROR: Could not read the CSV file." -ForegroundColor Red
    exit
}

# ================================
# Process Each User
# ================================
foreach ($User in $Users) {

    $Sam = $User.SamAccountName
    $NewPassword = New-RandomPassword

    # Convert to SecureString for AD
    $SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force

    try {
        # Reset AD password
        Set-ADAccountPassword -Identity $Sam -Reset -NewPassword $SecurePassword

        # Require user to change password at next logon
        Set-ADUser -Identity $Sam -ChangePasswordAtLogon $true

        Write-Host "Password updated for user: $Sam" -ForegroundColor Green

        # Add result to output
        $PasswordResults += [pscustomobject]@{
            SamAccountName = $Sam
            Password       = $NewPassword
        }
    }
    catch {
        Write-Host "ERROR resetting password for $Sam : $_" -ForegroundColor Red
    }
}

# ================================
# Export New Passwords To CSV
# ================================
$PasswordResults | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8

Write-Host "`nPasswords saved to: $OutputCSV" -ForegroundColor Cyan
Write-Host "Operation complete." -ForegroundColor Yellow