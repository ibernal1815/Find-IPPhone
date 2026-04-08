# Find-IPPhone

A PowerShell script that queries the `ipPhone` attribute in Active Directory. Built for helpdesk and sysadmin use when you need to find who owns a phone extension or what extension is assigned to a user.

## Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- RSAT Active Directory Domain Services Tools installed
- Domain-joined machine or network access to a domain controller
- Read permissions on AD user objects

## Usage

```powershell
.\Find-IPPhone.ps1
```

The script launches an interactive menu with three options:

**1. Search by IP Phone Number**
Enter an extension to find the AD user it is assigned to.

**2. Search by Username or Display Name**
Enter a SAM account name or display name. Wildcards are supported, for example `John*`.

**3. Export All IP Phones to CSV**
Exports every AD user with an ipPhone attribute set to a timestamped CSV in the current directory. Includes DisplayName, SamAccountName, ipPhone, Title, Department, Office, EmailAddress, and Enabled status.

## Notes

The ipPhone attribute must be populated in your directory for results to return. If the ActiveDirectory module is not found on launch, install RSAT on the machine running the script.

## License

MIT
