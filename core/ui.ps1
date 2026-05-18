# Yogi Artist Toolkit - UI Library
# A collection of beautiful, calming UI components.

$script:YogiQuietMode = $false

function Set-YogiQuietMode {
    param([switch]$Quiet)
    $script:YogiQuietMode = $Quiet
}

function Write-YogiHeader {
    param([string]$Text)
    if ($script:YogiQuietMode) { return }
    
    Write-Host ""
    Write-Host "🪷  $Text" -ForegroundColor Cyan
    Write-YogiDivider
}

function Write-YogiStep {
    param([string]$Text)
    if ($script:YogiQuietMode) { return }
    
    Write-Host "🎨 $Text..." -ForegroundColor DarkCyan
}

function Write-YogiSuccess {
    param([string]$Text)
    if ($script:YogiQuietMode) { return }
    
    Write-Host "🔥 $Text" -ForegroundColor Green
}

function Write-YogiWarning {
    param([string]$Text)
    if ($script:YogiQuietMode) { return }
    
    Write-Host "🌙 $Text" -ForegroundColor DarkYellow
}

function Write-YogiError {
    param([string]$Text)
    
    Write-Host ""
    Write-Host "🌧️  The flow was interrupted:" -ForegroundColor Red
    Write-Host "   $Text" -ForegroundColor Red
    Write-Host ""
}

function Write-YogiDivider {
    if ($script:YogiQuietMode) { return }
    Write-Host "   ----------------------------------------" -ForegroundColor DarkGray
}

function Show-YogiBanner {
    if ($script:YogiQuietMode) { return }
    
    Write-Host ""
    Write-Host "    🪷 Yogi Artist Toolkit" -ForegroundColor Cyan
    Write-Host "    Create. Clean. Flow." -ForegroundColor DarkGray
    Write-Host ""
}