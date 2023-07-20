<#
    .SYNOPSIS
        Updates Visual Studio.

    .LINK
        https://developercommunity.visualstudio.com/t/updating-visual-studio-via-command-line/953936
        https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022

        troubleshooting 
        https://learn.microsoft.com/en-us/troubleshoot/developer/visualstudio/installation/troubleshoot-installation-issues
#>

[CmdletBinding()]
param (
    [String]$LogPath = "C:\Temp",

    [Switch]$KeepExistingLog

    # [Parameter (Mandatory = $true)]
    # [String]$InstalledVersion
)

# Do we keep or overwrite log if it exists?
if ( $KeepExistingLog ) {
    $AppendLog = $True
}
Else {
    $AppendLog = $False
}

if ( -Not (Test-Path -Path $LogPath) ) { New-Item -Path $LogPath -ItemType Directory }

$LogFile = Join-Path -Path $LogPath -ChildPath VSUpdate.log

"$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - -----------" | Out-File -FilePath $LogFile -Append:$AppendLog
"$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - KeepExisting = $Appendlog" | Out-File -FilePath $LogFile -Append

# grab info about installed instances.
$VSInfo = Get-CimInstance MSFT_VSInstance -ErrorAction SilentlyContinue

# do we need to search for this file?
$VSInstallerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"

if ( $VSInfo ) {
    
    "$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - Visual Studio Installed Info:" | Out-File -FilePath $LogFile -Append
    "$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - $($VSInfo | Out-String)" | Out-File -FilePath $LogFile -Append

    "$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - Beginning to Update All Visual Studio." | Out-File -FilePath $LogFile -Append

    try {
        Start-Process -file $VSInstallerPath -ArgumentList "update --quiet --norestart --force --removeOos false --installPath ""$($VSInfo.InstallLocation)""" -Wait -ErrorAction Stop
    }
    Catch {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().fullname
        "$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - ERROR: Updating Vistual Studio. -- $ExceptionMessage`nSee log for more information: Location = $Env:Temp" | Out-File -FilePath $LogFile -Append
    }

    "$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - Update Complete. See Visual Studio logs for more information : $Env:Temp" | Out-File -FilePath $LogFile -Append
}
Else {
    "$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - Visual Studio is not installed" | Out-File -FilePath $LogFile -Append
}

"$(Get-Date -Format "yyy-MM-dd HH:mm:ss") - Script Complete" | Out-File -FilePath $LogFile -Append
