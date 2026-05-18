[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Load UI Core if available
$UIPath = Join-Path -Path $PSScriptRoot -ChildPath "..\core\ui.ps1"
if (Test-Path $UIPath) {
    . $UIPath
} else {
    function Write-YogiHeader($t) { Write-Host $t }
    function Write-YogiStep($t) { Write-Host $t }
    function Write-YogiSuccess($t) { Write-Host $t }
    function Write-YogiWarning($t) { Write-Host $t }
    function Write-YogiError($t) { Write-Host $t }
}

Write-YogiHeader "Terminal Profile Setup"

# Resolve Profile Path
$ProfilePath = $PROFILE
if (-not $ProfilePath) {
    # Fallback if $PROFILE is somehow not set
    $ProfilePath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

Write-YogiStep "Locating Profile at $ProfilePath"

# The source file we want to inject
$SourceFile = Join-Path -Path $PSScriptRoot -ChildPath "yogi-profile.ps1"
if (-not (Test-Path $SourceFile)) {
    # If not found relative to this script, check if we are in the installed location
    $SourceFile = Join-Path -Path $HOME -ChildPath "tools\yogi\terminal\yogi-profile.ps1"
}

$BlockStart = "# >>> YOGI ARTIST TOOLKIT >>>"
$BlockEnd   = "# <<< YOGI ARTIST TOOLKIT <<<"
$BlockContent = @"
$BlockStart
`$YogiArtistProfile = `"$SourceFile`"
if (Test-Path `$YogiArtistProfile) {
    . `$YogiArtistProfile
}
$BlockEnd
"@

if ($DryRun) {
    Write-YogiWarning "Dry Run: Would inject Yogi block into $ProfilePath"
    Write-YogiWarning "Dry Run: Block Content:`n$BlockContent"
    return
}

# 1. Ensure Profile Exists
if (-not (Test-Path $ProfilePath)) {
    Write-YogiStep "Creating new profile file"
    $ProfileDir = Split-Path $ProfilePath -Parent
    if (-not (Test-Path $ProfileDir)) {
        New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    }
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
}

# 2. Backup Profile
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupPath = "$ProfilePath.bak-$Timestamp"
Write-YogiStep "Backing up profile to $BackupPath"
Copy-Item -Path $ProfilePath -Destination $BackupPath -Force

# 3. Inject Block Safely
$ProfileContent = Get-Content -Path $ProfilePath -Raw
if ($null -eq $ProfileContent) { $ProfileContent = "" }

if ($ProfileContent -match $BlockStart) {
    if ($Force) {
        Write-YogiStep "Updating existing Yogi block"
        # Regex to match the block and replace it
        $Pattern = "(?s)$([regex]::Escape($BlockStart)).*?$([regex]::Escape($BlockEnd))"
        $NewContent = $ProfileContent -replace $Pattern, $BlockContent
        Set-Content -Path $ProfilePath -Value $NewContent
        Write-YogiSuccess "Yogi block updated successfully."
    } else {
        Write-YogiWarning "Yogi block already exists in your profile."
        Write-YogiWarning "Run with -Force to update it."
    }
} else {
    Write-YogiStep "Injecting Yogi block"
    # Ensure it ends with a newline before appending
    if ($ProfileContent.Length -gt 0 -and -not $ProfileContent.EndsWith("`n")) {
        $ProfileContent += "`n"
    }
    $ProfileContent += "`n$BlockContent`n"
    Set-Content -Path $ProfilePath -Value $ProfileContent
    Write-YogiSuccess "Yogi block injected successfully."
}

