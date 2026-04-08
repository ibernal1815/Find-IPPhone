# ============================================================
#  Find-IPPhone.ps1
#  Query IP Phone numbers from Active Directory
#  Author  : Isaiah Bernal (GitHub: ibernal1815
#  Requires: ActiveDirectory module (RSAT)
# ============================================================

#Requires -Modules ActiveDirectory

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Colour palette ───────────────────────────────────────────
$C = @{
    Accent  = 'Cyan'
    Success = 'Green'
    Warn    = 'Yellow'
    Error   = 'Red'
    Muted   = 'DarkGray'
    Header  = 'White'
}

# ── Helper: Draw a horizontal rule ───────────────────────────
function Write-Rule {
    param([string]$Char = '─', [int]$Width = 60)
    Write-Host ($Char * $Width) -ForegroundColor $C.Muted
}

# ── Helper: Section header ────────────────────────────────────
function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Rule
    Write-Host "  $Title" -ForegroundColor $C.Accent
    Write-Rule
}

# ── Helper: Print a key/value row ─────────────────────────────
function Write-Field {
    param([string]$Label, [string]$Value, [string]$ValueColor = $C.Header)
    $pad = $Label.PadRight(20)
    Write-Host "  $pad" -NoNewline -ForegroundColor $C.Muted
    Write-Host $Value -ForegroundColor $ValueColor
}

# ── Banner ────────────────────────────────────────────────────
function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ██╗██████╗     ██████╗ ██╗  ██╗ ██████╗ ███╗   ██╗███████╗" -ForegroundColor $C.Accent
    Write-Host "  ██║██╔══██╗    ██╔══██╗██║  ██║██╔═══██╗████╗  ██║██╔════╝" -ForegroundColor $C.Accent
    Write-Host "  ██║██████╔╝    ██████╔╝███████║██║   ██║██╔██╗ ██║█████╗  " -ForegroundColor $C.Accent
    Write-Host "  ██║██╔═══╝     ██╔═══╝ ██╔══██║██║   ██║██║╚██╗██║██╔══╝  " -ForegroundColor $C.Accent
    Write-Host "  ██║██║         ██║     ██║  ██║╚██████╔╝██║ ╚████║███████╗" -ForegroundColor $C.Accent
    Write-Host "  ╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝" -ForegroundColor $C.Accent
    Write-Host ""
    Write-Host "              IP Phone Lookup via Active Directory" -ForegroundColor $C.Muted
    Write-Host ""
    Write-Rule '═'
    Write-Host ""
}

# ── Search by IP Phone number ─────────────────────────────────
function Search-ByIPPhone {
    param([string]$PhoneNumber)

    Write-Host ""
    Write-Host "  [*] Searching for IP phone: " -NoNewline -ForegroundColor $C.Muted
    Write-Host $PhoneNumber -ForegroundColor $C.Accent

    try {
        $results = Get-ADUser -Filter { ipPhone -eq $PhoneNumber } `
            -Properties DisplayName, SamAccountName, ipPhone, `
                        Title, Department, Office, `
                        EmailAddress, Enabled, DistinguishedName

        if (-not $results) {
            Write-Host ""
            Write-Host "  [!] No user found with IP phone: $PhoneNumber" -ForegroundColor $C.Warn
            return
        }

        foreach ($user in $results) {
            Write-SectionHeader "RESULT — $($user.DisplayName)"
            Write-Field "Display Name"   (if ($user.DisplayName)    { $user.DisplayName }    else { '—' })
            Write-Field "SAM Account"    (if ($user.SamAccountName) { $user.SamAccountName } else { '—' })
            Write-Field "IP Phone"       (if ($user.ipPhone)        { $user.ipPhone }        else { '—' }) $C.Success
            Write-Field "Title"          (if ($user.Title)          { $user.Title }          else { '—' })
            Write-Field "Department"     (if ($user.Department)     { $user.Department }     else { '—' })
            Write-Field "Office"         (if ($user.Office)         { $user.Office }         else { '—' })
            Write-Field "Email"          (if ($user.EmailAddress)   { $user.EmailAddress }   else { '—' })
            Write-Field "Account Enabled" ($(if ($user.Enabled) { 'Yes' } else { 'No' })) `
                        $(if ($user.Enabled) { $C.Success } else { $C.Error })
            Write-Host ""
            Write-Host "  DN  " -NoNewline -ForegroundColor $C.Muted
            Write-Host $user.DistinguishedName -ForegroundColor $C.Muted
        }

    } catch {
        Write-Host ""
        Write-Host "  [ERROR] $_" -ForegroundColor $C.Error
    }
}

# ── Search by username / display name ─────────────────────────
function Search-ByUser {
    param([string]$Name)

    Write-Host ""
    Write-Host "  [*] Looking up user: " -NoNewline -ForegroundColor $C.Muted
    Write-Host $Name -ForegroundColor $C.Accent

    try {
        # Try SamAccountName first, then DisplayName wildcard
        $user = Get-ADUser -Filter { SamAccountName -eq $Name -or DisplayName -like $Name } `
            -Properties DisplayName, SamAccountName, ipPhone, `
                        Title, Department, Office, `
                        EmailAddress, Enabled, DistinguishedName |
            Select-Object -First 1

        if (-not $user) {
            Write-Host ""
            Write-Host "  [!] No user found matching: $Name" -ForegroundColor $C.Warn
            return
        }

        $phone = if ($user.ipPhone) { $user.ipPhone } else { '(not assigned)' }

        Write-SectionHeader "RESULT — $($user.DisplayName)"
        Write-Field "Display Name"    (if ($user.DisplayName)    { $user.DisplayName }    else { '—' })
        Write-Field "SAM Account"     (if ($user.SamAccountName) { $user.SamAccountName } else { '—' })
        Write-Field "IP Phone"        $phone $(if ($user.ipPhone) { $C.Success } else { $C.Warn })
        Write-Field "Title"           (if ($user.Title)          { $user.Title }          else { '—' })
        Write-Field "Department"      (if ($user.Department)     { $user.Department }     else { '—' })
        Write-Field "Office"          (if ($user.Office)         { $user.Office }         else { '—' })
        Write-Field "Email"           (if ($user.EmailAddress)   { $user.EmailAddress }   else { '—' })
        Write-Field "Account Enabled" ($(if ($user.Enabled) { 'Yes' } else { 'No' })) `
                    $(if ($user.Enabled) { $C.Success } else { $C.Error })
        Write-Host ""
        Write-Host "  DN  " -NoNewline -ForegroundColor $C.Muted
        Write-Host $user.DistinguishedName -ForegroundColor $C.Muted

    } catch {
        Write-Host ""
        Write-Host "  [ERROR] $_" -ForegroundColor $C.Error
    }
}

# ── Export results to CSV ──────────────────────────────────────
function Export-AllIPPhones {
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $outFile   = ".\IPPhones_Export_$timestamp.csv"

    Write-Host ""
    Write-Host "  [*] Pulling all users with an IP Phone assigned..." -ForegroundColor $C.Muted

    try {
        $users = Get-ADUser -Filter { ipPhone -like '*' } `
            -Properties DisplayName, SamAccountName, ipPhone, `
                        Title, Department, Office, EmailAddress, Enabled

        if (-not $users) {
            Write-Host "  [!] No results found." -ForegroundColor $C.Warn
            return
        }

        $users | Select-Object DisplayName, SamAccountName, ipPhone,
                                Title, Department, Office, EmailAddress, Enabled |
            Export-Csv -Path $outFile -NoTypeInformation

        Write-Host "  [✓] Exported $($users.Count) records to:" -ForegroundColor $C.Success
        Write-Host "      $((Resolve-Path $outFile).Path)" -ForegroundColor $C.Header

    } catch {
        Write-Host "  [ERROR] $_" -ForegroundColor $C.Error
    }
}

# ── Main menu loop ─────────────────────────────────────────────
function Show-Menu {
    Write-Host "  Select a search mode:" -ForegroundColor $C.Header
    Write-Host ""
    Write-Host "  [1]  Search by IP Phone number" -ForegroundColor $C.Accent
    Write-Host "  [2]  Search by Username / Display Name" -ForegroundColor $C.Accent
    Write-Host "  [3]  Export ALL IP phones to CSV" -ForegroundColor $C.Accent
    Write-Host "  [Q]  Quit" -ForegroundColor $C.Muted
    Write-Host ""
}

# ── Entry point ────────────────────────────────────────────────
Show-Banner

do {
    Show-Menu
    $choice = (Read-Host "  Enter choice").Trim().ToUpper()

    switch ($choice) {

        '1' {
            $phone = (Read-Host "`n  Enter IP Phone number (e.g. 12345)").Trim()
            if ($phone) { Search-ByIPPhone -PhoneNumber $phone }
            else        { Write-Host "  [!] No input provided." -ForegroundColor $C.Warn }
            Write-Host ""
            Pause
            Show-Banner
        }

        '2' {
            $name = (Read-Host "`n  Enter SAM Account or Display Name (wildcards OK, e.g. John*)").Trim()
            if ($name) { Search-ByUser -Name $name }
            else       { Write-Host "  [!] No input provided." -ForegroundColor $C.Warn }
            Write-Host ""
            Pause
            Show-Banner
        }

        '3' {
            Export-AllIPPhones
            Write-Host ""
            Pause
            Show-Banner
        }

        'Q' {
            Write-Host ""
            Write-Host "  Goodbye." -ForegroundColor $C.Muted
            Write-Host ""
        }

        default {
            Write-Host "  [!] Invalid choice. Please enter 1, 2, 3, or Q." -ForegroundColor $C.Warn
            Write-Host ""
        }
    }

} while ($choice -ne 'Q')
