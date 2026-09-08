' =============================================================================
' bootstrap/windows/ndw-ssh-autobackup-launcher.vbs
'
' Launches ndw-ssh-autobackup-check.ps1 with ZERO visible window.
' -WindowStyle Hidden on powershell.exe still flashes a console window
' briefly on some Windows versions when run from Task Scheduler; this
' VBScript wrapper avoids that entirely.
' =============================================================================

Set objShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
psScript = scriptDir & "\ndw-ssh-autobackup-check.ps1"

cmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & psScript & """"

' 0 = fully hidden window, False = don't wait for it to finish
objShell.Run cmd, 0, False
