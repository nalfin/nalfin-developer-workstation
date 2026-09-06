# =============================================================================
# bootstrap/windows/ndw-ssh-autobackup-setup.ps1
#
# One-time setup for automatic SSH backup. Run this ONCE from PowerShell
# (not Git Bash):
#
#   powershell -ExecutionPolicy Bypass -File bootstrap/windows/ndw-ssh-autobackup-setup.ps1
#
# What it does:
#   1. Asks for your SSH backup encryption password once, stores it
#      DPAPI-encrypted at ~/.ndw/ssh-backup.secret (only your Windows
#      account on this machine can decrypt it).
#   2. Registers a Scheduled Task that runs at every login, and every
#      hour while logged in, checking whether ~/.ssh changed since the
#      last backup - only backing up when it actually did.
# =============================================================================

$ErrorActionPreference = "Stop"

$ndwDir = Join-Path $env:USERPROFILE ".ndw"
New-Item -ItemType Directory -Force -Path $ndwDir | Out-Null

Write-Host ""
Write-Host "NDW - SSH Auto Backup Setup" -ForegroundColor Cyan
Write-Host "----------------------------------------"
Write-Host "This password will be used automatically whenever ~/.ssh changes."
Write-Host "It's stored encrypted, tied to your Windows account on this device only."
Write-Host ""

$securePw = Read-Host "Enter SSH backup encryption password" -AsSecureString
$securePw2 = Read-Host "Confirm password" -AsSecureString

$bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePw)
$bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePw2)
$plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
$plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)

if ($plain1 -ne $plain2) {
    Write-Host "Passwords do not match. Aborting." -ForegroundColor Red
    exit 1
}
$plain1 = $null
$plain2 = $null

$encrypted = ConvertFrom-SecureString $securePw
$secretPath = Join-Path $ndwDir "ssh-backup.secret"
$encrypted | Out-File -FilePath $secretPath -Encoding utf8 -NoNewline
Write-Host "Password saved (encrypted) to $secretPath" -ForegroundColor Green

# Reset the "last backup" hash so the first check run does a fresh backup.
$hashPath = Join-Path $ndwDir "ssh-last-hash.txt"
if (Test-Path $hashPath) { Remove-Item $hashPath }

$ndwRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$checkScript = Join-Path $PSScriptRoot "ndw-ssh-autobackup-check.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$checkScript`""

$triggerLogon = New-ScheduledTaskTrigger -AtLogOn
$triggerHourly = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Hours 1) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "NDW-SSH-AutoBackup" `
    -Action $action `
    -Trigger @($triggerLogon, $triggerHourly) `
    -Settings $settings `
    -Description "Backs up ~/.ssh to Google Drive via NDW, only when it has changed." `
    -Force | Out-Null

Write-Host "Scheduled Task 'NDW-SSH-AutoBackup' registered (runs at login + hourly)." -ForegroundColor Green
Write-Host ""
Write-Host "Done. Your first automatic backup will run within the hour, or at next login." -ForegroundColor Cyan
Write-Host "To remove this later: bootstrap/windows/ndw-ssh-autobackup-remove.ps1"
Write-Host ""
