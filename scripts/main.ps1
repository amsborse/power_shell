[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = "help",
    
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ArgsRemaining,
    
    [switch]$quiet,
    [switch]$dryRun,
    [switch]$help
)

$ErrorActionPreference = "Stop"

# Load UI Core
$UIPath = Join-Path -Path $PSScriptRoot -ChildPath "..\core\ui.ps1"
if (Test-Path $UIPath) {
    . $UIPath
}

if ($quiet) { Set-YogiQuietMode -Quiet }

if ($help) {
    $Command = "help"
}

function Show-Help {
    Show-YogiBanner
    Write-Host "Usage:" -ForegroundColor DarkGray
    Write-Host "  yogi install"
    Write-Host "  yogi update"
    Write-Host "  yogi open"
    Write-Host "  yogi theme [install|remove|info]"
    Write-Host "  yogi help"
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor DarkGray
    Write-Host "  install     Install the toolkit"
    Write-Host "  update      Pull latest changes"
    Write-Host "  open        Open the toolkit folder"
    Write-Host "  theme       Manage the Yogi terminal theme"
    Write-Host "  help        Show help"
    Write-Host ""
    Write-Host "Flags:" -ForegroundColor DarkGray
    Write-Host "  --quiet     Silence all non-error output"
    Write-Host "  --verbose   Show detailed flow"
    Write-Host "  --dry-run   Preview actions without changing the path"
    Write-Host ""
}

switch ($Command.ToLower()) {
    "help" {
        Show-Help
    }
    "install" {
        $InstallScript = Join-Path -Path $PSScriptRoot -ChildPath "..\install.ps1"
        if (Test-Path $InstallScript) {
            & $InstallScript -quiet:$quiet -dryRun:$dryRun
        } else {
            Write-YogiError "The installation script is not in the flow."
        }
    }
    "update" {
        Write-YogiHeader "Refreshing Your Space"
        Write-YogiStep "Pulling latest changes from the origin"
        
        if ($dryRun) {
            Write-YogiWarning "Dry run enabled. Skipping update."
        } else {
            if (Get-Command git -ErrorAction SilentlyContinue) {
                $OriginalDir = Get-Location
                Set-Location -Path (Join-Path -Path $PSScriptRoot -ChildPath "..")
                git pull | Out-Null
                Set-Location -Path $OriginalDir
                Write-YogiSuccess "Update complete. Your toolkit is renewed."
            } else {
                Write-YogiWarning "Git is not installed. Please download the latest version manually."
            }
        }
    }
    "open" {
        Write-YogiStep "Opening your creative workspace"
        $RepoRoot = Join-Path -Path $PSScriptRoot -ChildPath ".."
        Invoke-Item $RepoRoot
        Write-YogiSuccess "The path is clear."
    }
    "theme" {
        $SubCommand = if ($ArgsRemaining.Count -gt 0) { $ArgsRemaining[0].ToLower() } else { "help" }
        $SetupScript = Join-Path -Path $PSScriptRoot -ChildPath "..\terminal\setup-profile.ps1"
        
        switch ($SubCommand) {
            "install" {
                if (Test-Path $SetupScript) {
                    & $SetupScript -Force -DryRun:$dryRun
                } else {
                    Write-YogiError "The setup script is missing."
                }
            }
            "remove" {
                $UninstallScript = Join-Path -Path $PSScriptRoot -ChildPath "..\uninstall.ps1"
                if (Test-Path $UninstallScript) {
                    & $UninstallScript -RemoveTerminalProfile -quiet:$quiet
                } else {
                    Write-YogiError "The uninstallation script is missing."
                }
            }
            "info" {
                $ProfileScript = Join-Path -Path $PSScriptRoot -ChildPath "..\terminal\yogi-profile.ps1"
                if (Test-Path $ProfileScript) {
                    . $ProfileScript
                    yogi-theme-info
                } else {
                    Write-YogiError "The profile script is missing."
                }
            }
            default {
                Write-YogiWarning "Usage: yogi theme [install|remove|info]"
            }
        }
    }
    default {
        Write-YogiError "The command '$Command' is not part of the flow."
        Show-Help
    }
}

