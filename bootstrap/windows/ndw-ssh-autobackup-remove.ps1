# =============================================================================
# bootstrap/windows/ndw-ssh-autobackup-remove.ps1
#
# Removes the auto-backup Scheduled Task and deletes the stored password.
# Run from PowerShell:
#
#   powershell -ExecutionPolicy Bypass -File bootstrap/windows/ndw-ssh-autobackup-remove.ps1
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"

Unregister-ScheduledTask -TaskName "NDW-SSH-AutoBackup" -Confirm:$false
Write-Host "Removed Scheduled Task 'NDW-SSH-AutoBackup'." -ForegroundColor Green

$ndwDir = Join-Path $env:USERPROFILE ".ndw"
Remove-Item (Join-Path $ndwDir "ssh-backup.secret") -Force
Remove-Item (Join-Path $ndwDir "ssh-last-hash.txt") -Force

Write-Host "Removed stored password and hash. Auto-backup is now fully disabled." -ForegroundColor Green
Write-Host "(Log file at $ndwDir\autobackup.log left in place, delete manually if you want.)"
