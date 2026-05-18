[CmdletBinding()]
param(
    [switch]$quiet,
    [switch]$dryRun,
    [switch]$InstallTerminalProfile,
    [switch]$SkipTerminalProfile,
    [switch]$InstallOptionalDependencies
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
Write-YogiHeader "Preparing Your Workspace"

$ToolName = "yogi"
$InstallDir = Join-Path -Path $HOME -ChildPath "tools\$ToolName"
$BinDir = Join-Path -Path $InstallDir -ChildPath "bin"

try {
    # 1. Create install directory
    Write-YogiStep "Locating installation path ($InstallDir)"
    if ($dryRun) {
        Write-YogiWarning "Dry run: would create or overwrite $InstallDir"
    } else {
        if (-not (Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        }
    }

    # 2. Copy files to install directory
    Write-YogiStep "Arranging the files"
    if ($dryRun) {
        Write-YogiWarning "Dry run: would copy files from $PSScriptRoot to $InstallDir"
    } else {
        Copy-Item -Path "$PSScriptRoot\*" -Destination $InstallDir -Recurse -Force -Exclude ".git"
    }

    # 3. Add to User PATH
    Write-YogiStep "Harmonizing with your environment"
    $UserPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    $PathArray = if ($UserPath) { $UserPath -split ';' } else { @() }

    if ($PathArray -contains $BinDir) {
        Write-YogiWarning "The path is already aligned. No changes needed."
    } else {
        if ($dryRun) {
            Write-YogiWarning "Dry run: would add $BinDir to PATH"
        } else {
            $NewPath = if ([string]::IsNullOrWhiteSpace($UserPath)) { $BinDir } else { "$UserPath;$BinDir" }
            $NewPath = $NewPath -replace ';;+', ';' -replace ';$', ''
            [Environment]::SetEnvironmentVariable("PATH", $NewPath, [System.EnvironmentVariableTarget]::User)
            Write-YogiSuccess "Environment updated."
        }
    }

    # 4. Optional Dependencies
    if ($InstallOptionalDependencies) {
        Write-YogiHeader "Installing Optional Dependencies"
        Write-YogiStep "Checking tools..."
        if (-not $dryRun) {
            Write-YogiWarning "Running winget. This may take some time..."
            winget install Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements
            winget install JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements --accept-source-agreements
            winget install DEVCOM.JetBrainsMonoNerdFont --silent --accept-package-agreements --accept-source-agreements
            Write-YogiSuccess "Optional dependencies processed."
        }
    }

    # 5. Terminal Profile
    $DoInstallProfile = $false
    if ($InstallTerminalProfile) {
        $DoInstallProfile = $true
    } elseif (-not $SkipTerminalProfile -and -not $quiet -and [Environment]::UserInteractive) {
        Write-Host ""
        $Confirmation = Read-Host "Install Yogi Artist terminal profile enhancements? [Y/n]"
        if ($Confirmation -notmatch "^n(o)?`$") {
            $DoInstallProfile = $true
        }
    }

    if ($DoInstallProfile) {
        Write-YogiHeader "Terminal Profile setup"
        $ProfileSetupPath = Join-Path -Path $InstallDir -ChildPath "terminal\setup-profile.ps1"
        if (Test-Path $ProfileSetupPath) {
            & $ProfileSetupPath -Force -DryRun:$dryRun
        } else {
            Write-YogiWarning "Terminal setup script not found at $ProfileSetupPath"
        }
    }

    Write-Host ""
    Write-YogiSuccess "Installation complete. The canvas is ready."
    
    if (-not $quiet) {
        Write-Host "    ðŸŒ™ Please restart your terminal, or open a new one," -ForegroundColor DarkGray
        Write-Host "       to experience the new flow." -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "    Try running: " -NoNewline -ForegroundColor DarkGray
        Write-Host "yogi help" -ForegroundColor Cyan
    }
    Write-Host ""
}
catch {
    Write-YogiError $_.Exception.Message
}

