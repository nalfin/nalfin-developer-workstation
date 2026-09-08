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

$ndwDir = Join-Path $env:USERPROFILE ".ndw"
$secretPath = Join-Path $ndwDir "ssh-backup.secret"
$hashPath = Join-Path $ndwDir "ssh-last-hash.txt"
$sshPath = Join-Path $env:USERPROFILE ".ssh"
$logPath = Join-Path $ndwDir "autobackup.log"
$transcriptPath = Join-Path $ndwDir "transcript.log"

New-Item -ItemType Directory -Force -Path $ndwDir | Out-Null
Start-Transcript -Path $transcriptPath -Append | Out-Null

function Write-Log($msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg"
    Write-Host $line
    try {
        Add-Content -Path $logPath -Value $line -Encoding utf8
    } catch {
        Write-Host "  (could not write to log file: $_)" -ForegroundColor Yellow
    }
}

try {
    [Console]::WriteLine("Checkpoint 1: entered try block")
    Write-Log "Check started."
    [Console]::WriteLine("Checkpoint 2: logged start")

    if (-not (Test-Path $secretPath)) {
        Write-Log "No stored password found at $secretPath - run ndw-ssh-autobackup-setup.ps1 first. Skipping."
        exit 0
    }
    [Console]::WriteLine("Checkpoint 3: secret exists")

    if (-not (Test-Path $sshPath)) {
        Write-Log "No ~/.ssh directory found at $sshPath. Skipping."
        exit 0
    }
    [Console]::WriteLine("Checkpoint 4: ssh dir exists")

    # Hash based on file paths + sizes + mtimes - cheap, no need to read file contents.
    $files = Get-ChildItem -Path $sshPath -Recurse -File -ErrorAction Stop
    $manifest = ($files | Sort-Object FullName | ForEach-Object {
        "$($_.FullName)|$($_.Length)|$($_.LastWriteTimeUtc.Ticks)"
    }) -join "`n"

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($manifest))
    $currentHash = [BitConverter]::ToString($hashBytes) -replace '-', ''

    $lastHash = ""
    if (Test-Path $hashPath) {
        $lastHash = (Get-Content $hashPath -Raw).Trim()
    }

    Write-Log "Files in ~/.ssh: $($files.Count). Current hash: $currentHash. Last hash: $lastHash"
    [Console]::WriteLine("Checkpoint 5: hash computed")

    if ($currentHash -eq $lastHash) {
        Write-Log "No change detected. Nothing to do."
        exit 0
    }

    Write-Log "Change detected in ~/.ssh - running backup..."

    # Locate bash.exe (Git for Windows)
    $bashCandidates = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )
    $bash = $bashCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $bash) {
        Write-Log "ERROR: could not find bash.exe (Git for Windows) in any of: $($bashCandidates -join ', ')"
        exit 1
    }
    Write-Log "Using bash: $bash"

    # Bash/Git Bash outputs UTF-8 (box-drawing chars, checkmarks, etc. from
    # ndw's colored output). Without this, PowerShell misreads those bytes
    # using the system codepage and garbles them in the log.
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

    Write-Log "--- ndw backup --ssh --auto output ---"
    Write-Log ($output | Out-String)
    Write-Log "--- end output (exit code: $exitCode) ---"

    if ($exitCode -eq 0) {
        $currentHash | Out-File -FilePath $hashPath -Encoding utf8 -NoNewline
        Write-Log "Backup succeeded, hash updated."
    } else {
        Write-Log "Backup FAILED (exit $exitCode) - hash not updated, will retry next check."
    }
} catch {
    [Console]::WriteLine("UNEXPECTED ERROR: " + $_.Exception.Message)
    [Console]::WriteLine($_.ScriptStackTrace)
    try {
        Add-Content -Path $logPath -Value ("$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  UNEXPECTED ERROR: " + $_.Exception.Message) -Encoding utf8
    } catch {}
    exit 1
} finally {
    Stop-Transcript | Out-Null
}
