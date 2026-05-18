[CmdletBinding()]
param(
    [switch]$quiet,
    [switch]$force,
    [switch]$RemoveTerminalProfile
)

$ErrorActionPreference = "Stop"

# Load UI Core
$UIPath = Join-Path -Path $PSScriptRoot -ChildPath "core\ui.ps1"
if (Test-Path $UIPath) {
    . $UIPath
} else {
    function Write-YogiHeader($t) { Write-Host $t }
    function Write-YogiStep($t) { Write-Host $t }
    function Write-YogiSuccess($t) { Write-Host $t }
    function Write-YogiWarning($t) { Write-Host $t }
    function Write-YogiError($t) { Write-Host $t }
    function Show-YogiBanner {}
}

if ($quiet) { Set-YogiQuietMode -Quiet }

Show-YogiBanner
Write-YogiHeader "Releasing the Workspace"

$ToolName = "yogi"
$InstallDir = Join-Path -Path $HOME -ChildPath "tools\$ToolName"
$BinDir = Join-Path -Path $InstallDir -ChildPath "bin"

try {
    # 1. Ask for confirmation unless -force is used
    if (-not $force -and -not $quiet -and [Environment]::UserInteractive) {
        $Confirmation = Read-Host "Are you sure you want to release the Yogi toolkit? (y/N)"
        if ($Confirmation -notmatch "^y(es)?`$") {
            Write-YogiWarning "Release cancelled. The toolkit remains."
            exit 0
        }
    }

    # 2. Terminal Profile Cleanup
    $DoRemoveProfile = $false
    if ($RemoveTerminalProfile) {
        $DoRemoveProfile = $true
    } elseif (-not $force -and -not $quiet -and [Environment]::UserInteractive) {
        $ProfileConfirmation = Read-Host "Remove Yogi Artist terminal profile enhancements? (y/N)"
        if ($ProfileConfirmation -match "^y(es)?`$") {
            $DoRemoveProfile = $true
        }
    }

    if ($DoRemoveProfile) {
        Write-YogiStep "Releasing terminal profile"
        if (Test-Path $PROFILE) {
            $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $BackupPath = "$PROFILE.bak-$Timestamp"
            Write-YogiStep "Backing up profile to $BackupPath"
            Copy-Item -Path $PROFILE -Destination $BackupPath -Force
            
            $ProfileContent = Get-Content -Path $PROFILE -Raw
            $BlockStart = "# >>> YOGI ARTIST TOOLKIT >>>"
            $BlockEnd   = "# <<< YOGI ARTIST TOOLKIT <<<"
            
            if ($ProfileContent -match $BlockStart) {
                # Regex to match the block and replace it with nothing
                $Pattern = "(?s)\r?\n?$([regex]::Escape($BlockStart)).*?$([regex]::Escape($BlockEnd))\r?\n?"
                $NewContent = $ProfileContent -replace $Pattern, "`n"
                Set-Content -Path $PROFILE -Value $NewContent
                Write-YogiSuccess "Yogi block removed from profile."
            } else {
                Write-YogiWarning "Yogi block not found in profile."
            }
        } else {
            Write-YogiWarning "Profile does not exist."
        }
    }

    # 3. Remove from PATH
    Write-YogiStep "Clearing the path"
    $UserPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    
    if (-not [string]::IsNullOrWhiteSpace($UserPath)) {
        $PathArray = $UserPath -split ';'
        $FilteredPathArray = $PathArray | Where-Object { $_ -ne $BinDir }
        
        if ($PathArray.Count -ne $FilteredPathArray.Count) {
            $NewPath = $FilteredPathArray -join ';'
            [Environment]::SetEnvironmentVariable("PATH", $NewPath, [System.EnvironmentVariableTarget]::User)
            Write-YogiSuccess "Path cleared gracefully."
        } else {
            Write-YogiWarning "The path was already clear."
        }
    }

    # 4. Remove files
    Write-YogiStep "Dissolving the tools"
    if (Test-Path $InstallDir) {
        # Check if we are currently running from within the install dir
        if ($PSScriptRoot -eq $InstallDir) {
            Write-YogiWarning "You are running this from the installation directory."
            Write-YogiWarning "Cannot delete files while they are in use."
            Write-YogiWarning "Please manually remove $InstallDir later."
        } else {
            Remove-Item -Path $InstallDir -Recurse -Force
            Write-YogiSuccess "Files returned to the void."
        }
    } else {
        Write-YogiWarning "No installed files found at $InstallDir."
    }

    Write-Host ""
    Write-YogiSuccess "Uninstallation complete. You are released."
    Write-Host ""
}
catch {
    Write-YogiError $_.Exception.Message
}

