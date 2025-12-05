# 🛡️Active-Directory-Bulk-User-Creation-Script-PowerShell-

This project demonstrates an automation script that creates multiple Active Directory user accounts, adds them to a group, and forces each user to reset their password at first logon.
This is perfect for homelabs, cybersecurity portfolios, and system administration practice.

---

# #🚀 Features

* Bulk-create AD user accounts
* Add **users** to a specified **AD** group
* Force **password reset** on next logon
* Clean, readable PowerShell script
* Easy to customize for any **domain environment**

---

# #📌 Requirements

* **Windows Server** or **Windows 10/11** joined to a domain
* **RSAT**?tools installed (Active Directory PowerShell module)
* **PowerShell** run as **Administrator**
* **AD permissions** to create accounts

---

# #🛠 How the Script Works

The script:
1. Imports the Active Directory PowerShell module
2. Reads a list of usernames
3. Creates each user in a specified OU
4. Sets a temporary password
5. Forces password change at next logon
6. Adds each user to an AD group

---

# #📄 PowerShell Script

```powershell
Import-Module ActiveDirectory

# -----------------------------------------------
# List of AD accounts to create
# Add or remove names as needed
# -----------------------------------------------
$userList = @(
    "Alice",
    "Bob",
    "Charlie",
    "David",
    "Emma",
    "Frank",
    "Grace",
    "Hiro",
    "Isabella",
    "Jack"
)

# -----------------------------------------------
# Temporary password (must meet domain complexity)
# -----------------------------------------------
$tempPassword = "TempP@ssw0rd123"
$securePassword = ConvertTo-SecureString $tempPassword -AsPlainText -Force

# -----------------------------------------------
# OU where the new accounts will be created
# EDIT THESE VALUES TO MATCH YOUR DOMAIN
# -----------------------------------------------
$targetOU = "OU=Users,DC=corp,DC=local"

# -----------------------------------------------
# AD group where all users will be added
# All users go into the SAME group
# -----------------------------------------------
$groupName = "Users"

# -----------------------------------------------
# Main user creation loop
# -----------------------------------------------
foreach ($username in $userList) {

    # Check if user already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue) {
        Write-Host "User '$username' already exists. Skipping..."
        continue
    }

    # Create user
    New-ADUser `
        -Name $username `
        -SamAccountName $username `
        -UserPrincipalName "$username@YourDomain.com" `
        -AccountPassword $securePassword `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -Path $targetOU

    # Add user to AD group
    Add-ADGroupMember -Identity $groupName -Members $username

    Write-Host "Created AD user: $username | Password reset on next login | Added to '$groupName'"
}

Write-Host "Finished creating all AD users."
```

---

# #▶️ How to Run
	
1. Clone or download this repository
2. Copy the code from the README into a .ps1 file
3. Edit the domain, OU, and user list as needed
4. Run using:
```bash
.\Create-AD-Users.ps1
```

---

# #📸 Screenshots

*![Active Directory Users Created]()
*![PowerShell Script Output]()
*![User Properties in ADUC]()










