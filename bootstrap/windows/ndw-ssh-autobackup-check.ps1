# =============================================================================
# bootstrap/windows/ndw-ssh-autobackup-check.ps1
#
# Called by the "NDW-SSH-AutoBackup" Scheduled Task (login + hourly).
# NOT meant to be run manually, but it's harmless to do so.
#
# Compares a hash of ~/.ssh's contents against the last backed-up hash.
# If unchanged, does nothing (no network call, no password decryption).
# If changed, decrypts the stored password and runs `ndw backup --ssh --auto`.
# =============================================================================

$ErrorActionPreference = "Stop"

$ndwDir = Join-Path $env:USERPROFILE ".ndw"
$secretPath = Join-Path $ndwDir "ssh-backup.secret"
$hashPath = Join-Path $ndwDir "ssh-last-hash.txt"
$sshPath = Join-Path $env:USERPROFILE ".ssh"
$logPath = Join-Path $ndwDir "autobackup.log"

function Write-Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File -FilePath $logPath -Append -Encoding utf8
}

if (-not (Test-Path $secretPath)) {
    Write-Log "No stored password found — run ndw-ssh-autobackup-setup.ps1 first. Skipping."
    exit 0
}

if (-not (Test-Path $sshPath)) {
    Write-Log "No ~/.ssh directory found. Skipping."
    exit 0
}

# Hash based on file paths + sizes + mtimes — cheap, no need to read file contents.
$manifest = Get-ChildItem -Path $sshPath -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object FullName |
    ForEach-Object { "$($_.FullName)|$($_.Length)|$($_.LastWriteTimeUtc.Ticks)" } |
    Out-String

$sha256 = [System.Security.Cryptography.SHA256]::Create()
$hashBytes = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($manifest))
$currentHash = [BitConverter]::ToString($hashBytes) -replace '-', ''

$lastHash = if (Test-Path $hashPath) { Get-Content $hashPath -Raw } else { "" }

if ($currentHash -eq $lastHash.Trim()) {
    # Nothing changed since last backup — do nothing.
    exit 0
}

Write-Log "Change detected in ~/.ssh — running backup..."

# Locate bash.exe (Git for Windows)
$bashCandidates = @(
    "$env:ProgramFiles\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)
$bash = $bashCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $bash) {
    Write-Log "ERROR: could not find bash.exe (Git for Windows). Skipping backup."
    exit 1
}

# Decrypt the stored password just long enough to pass it to bash.
$encrypted = Get-Content $secretPath -Raw
$secureString = ConvertTo-SecureString $encrypted
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
$plainPw = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

$env:NDW_SSH_BACKUP_PASSWORD = $plainPw
$output = & $bash -lc "ndw backup --ssh --auto" 2>&1
$exitCode = $LASTEXITCODE
Remove-Item Env:\NDW_SSH_BACKUP_PASSWORD
$plainPw = $null

Write-Log ($output -join "`n")

if ($exitCode -eq 0) {
    $currentHash | Out-File -FilePath $hashPath -Encoding utf8 -NoNewline
    Write-Log "Backup succeeded, hash updated."
} else {
    Write-Log "Backup FAILED (exit $exitCode) — hash not updated, will retry next check."
}
