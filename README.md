# Find-IPPhone

A PowerShell interactive menu tool for querying IP phone assignments stored in Active Directory. Useful for helpdesk and sysadmin workflows where you need to quickly identify who owns a phone extension — or find what extension a user has been assigned.

---

## Features

- Search by IP phone number → returns the assigned user
- Search by SAM account name or display name (wildcards supported) → returns their phone info
- Export all users with an IP phone assigned to a timestamped CSV
- Color-coded terminal output for quick readability
- Graceful error handling for unmatched queries

---

## Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- [RSAT: Active Directory Domain Services Tools](https://learn.microsoft.com/en-us/windows-server/remote/remote-server-administration-tools) installed
- Domain-joined machine **or** network access to a domain controller
- Read permissions on Active Directory user objects

---

## Installation

No installation required. Clone or download the script and run it directly.

```powershell
git clone https://github.com/YOUR_USERNAME/Find-IPPhone.git
cd Find-IPPhone
```

---

## Usage

```powershell
.\Find-IPPhone.ps1
```

You'll be presented with an interactive menu:

```
  [1]  Search by IP Phone number
  [2]  Search by Username / Display Name
  [3]  Export ALL IP phones to CSV
  [Q]  Quit
```

### Option 1 — Search by IP Phone
Enter an extension (e.g. `12345`) to find the AD user it's assigned to.

### Option 2 — Search by Username / Display Name
Enter a SAM account name (e.g. `jdoe`) or a display name with optional wildcards (e.g. `John*`).

### Option 3 — Export to CSV
Dumps all AD users with an `ipPhone` attribute set to a CSV file in the current directory. File is timestamped automatically:
```
IPPhones_Export_20250408_143022.csv
```
Exported fields: `DisplayName`, `SamAccountName`, `ipPhone`, `Title`, `Department`, `Office`, `EmailAddress`, `Enabled`

---

## Notes

- IP phone numbers are pulled from the `ipPhone` attribute on AD user objects. This field must be populated in your directory for results to appear.
- The script uses `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` — errors will surface clearly rather than fail silently.
- If you get a module error on launch, ensure the ActiveDirectory PowerShell module is installed via RSAT.

---

## License

MIT
