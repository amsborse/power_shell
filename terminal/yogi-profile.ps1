# ============================================================
# Yogi Artist PowerShell Profile
# Premium terminal experience for Windows PowerShell / PS7
# ============================================================

$global:YogiArtistLoaded = $true

$script:YA = @{
    Pink  = "Magenta"
    Gold  = "Yellow"
    Teal  = "Cyan"
    Green = "Green"
    Gray  = "DarkGray"
    Soft  = "Gray"
    Red   = "Red"
    White = "White"
}

function Write-YA {
    param(
        [string]$Text,
        [string]$Color = "Gray",
        [switch]$NoNewline
    )

    if ($NoNewline) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Get-YAWidth {
    try {
        return [Math]::Max(80, $Host.UI.RawUI.WindowSize.Width)
    } catch {
        return 100
    }
}

function Write-YACentered {
    param(
        [string]$Text,
        [string]$Color = "Gray"
    )

    $width = Get-YAWidth
    $plainLength = $Text.Length
    $pad = [Math]::Max(0, [Math]::Floor(($width - $plainLength) / 2))
    Write-YA (" " * $pad + $Text) $Color
}

function Write-YAAt {
    param(
        [int]$Left,
        [int]$Top,
        [string]$Text,
        [string]$Color = "Gray"
    )

    try {
        $pos = $Host.UI.RawUI.CursorPosition
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $Left, $Top
        Write-YA $Text $Color
        $Host.UI.RawUI.CursorPosition = $pos
    } catch {
        Write-YA $Text $Color
    }
}

function Get-YAShortPath {
    param([string]$Path = (Get-Location).Path)

    $homePath = [Environment]::GetFolderPath("UserProfile")

    if ($Path.StartsWith($homePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "~" + $Path.Substring($homePath.Length)
    }

    $p = $Path -replace "\\", "/"
    $p = $p -replace "1 - Projects/Projects", "projects"

    return ($p -replace "/", "\").ToLower()
}

function Get-YAGitBranch {
    try {
        $branch = git branch --show-current 2>$null
        if ([string]::IsNullOrWhiteSpace($branch)) { return $null }

        $dirty = git status --porcelain 2>$null
        if ($dirty) { return "$branch ✦" }

        return "$branch ●"
    } catch {
        return $null
    }
}

function Write-YAInfoCards {
    $width = Get-YAWidth
    if ($width -lt 120) { return }

    $psVersion = $PSVersionTable.PSVersion.ToString()
    $edition = if ($PSVersionTable.PSEdition) { $PSVersionTable.PSEdition } else { "Desktop" }

    $left = 4
    $right = [Math]::Max(70, $width - 42)
    $top = 5

    Write-YAAt $left $top     "╭────────────────────────────────────╮" $script:YA.Gray
    Write-YAAt $left ($top+1) "│  🧘 Stay centered.                 │" $script:YA.Soft
    Write-YAAt $left ($top+2) "│  Build intentionally.              │" $script:YA.Soft
    Write-YAAt $left ($top+3) "╰────────────────────────────────────╯" $script:YA.Gray

    Write-YAAt $right $top     "╭──────────────────────────────╮" $script:YA.Gray
    Write-YAAt $right ($top+1) "│    PowerShell $psVersion" $script:YA.Soft
    Write-YAAt $right ($top+2) "│    Windows Terminal" $script:YA.Soft
    Write-YAAt $right ($top+3) "│  Aa  Nerd Font recommended" $script:YA.Gold
    Write-YAAt $right ($top+4) "╰──────────────────────────────╯" $script:YA.Gray
}

function Write-YAYogiArt {
    Write-Host ""

    # top aura
    Write-YACentered "           ◜────────◝" "Magenta"
    Write-YACentered "             ◝────◜" "Magenta"

    # head / consciousness loop
    Write-YACentered "               𝝮" "Cyan"

    # upper body (flowing inward)
    Write-YACentered "            ╭──┴──╮" "Cyan"
    Write-YACentered "          ╭─╯     ╰─╮" "Green"

    # heart center
    Write-YACentered "         │    ♥     │" "Yellow"

    # body expanding outward
    Write-YACentered "          ╰─╮     ╭─╯" "Green"
    Write-YACentered "            ╰──┬──╯" "Cyan"

    # lotus base (infinity legs)
    Write-YACentered "        ◜──────┴──────◝" "Yellow"
    Write-YACentered "      ◜───────┼───────◝" "Red"
    Write-YACentered "    ◜─────────┴─────────◝" "Red"

    Write-Host ""
}

function Write-YAStartupBanner {
    if ($global:YogiArtistBannerShown) { return }
    $global:YogiArtistBannerShown = $true

    Clear-Host

    Write-YAYogiArt
    Write-YACentered "Y  O  G  I     A  R  T  I  S  T" $script:YA.Pink
    Write-YACentered "CREATE  •  FOCUS  •  FLOW" $script:YA.Teal
    Write-YACentered "───────────────  ❖  ───────────────" $script:YA.Gray
    Write-Host ""

    Write-YAInfoCards

    Write-Host ""
    Write-Host ""
}

function Write-YAPromptBar {
    $time = Get-Date -Format "HH:mm"
    $date = Get-Date -Format "MMM dd"
    $path = Get-YAShortPath
    $branch = Get-YAGitBranch

    $width = Get-YAWidth
    $promptWidth = [Math]::Min(120, [Math]::Max(80, $width - 8))
    $leftPad = [Math]::Max(0, [Math]::Floor(($width - $promptWidth) / 2))

    $pad = " " * $leftPad

    Write-Host ""

    Write-YA $pad $script:YA.Gray -NoNewline
    Write-YA "╭─" $script:YA.Gray -NoNewline
    Write-YA " 🪷 " $script:YA.Pink -NoNewline
    Write-YA "─[" $script:YA.Gray -NoNewline
    Write-YA " ◷ $time " $script:YA.Gold -NoNewline
    Write-YA "]─[" $script:YA.Gray -NoNewline
    Write-YA "  $date " $script:YA.Pink -NoNewline
    Write-YA "]─[" $script:YA.Gray -NoNewline
    Write-YA " 📁 $path " $script:YA.Teal -NoNewline
    Write-YA "]" $script:YA.Gray -NoNewline

    if ($branch) {
        Write-YA "─[" $script:YA.Gray -NoNewline
        Write-YA " ⎇ $branch " $script:YA.Gold -NoNewline
        Write-YA "]" $script:YA.Gray -NoNewline
    }

    Write-YA "─╮" $script:YA.Gray

    Write-YA $pad $script:YA.Gray -NoNewline
    Write-YA "╰─" $script:YA.Gray -NoNewline
    Write-YA "❯ " $script:YA.Teal -NoNewline
}

function prompt {
    Write-YAPromptBar
    return " "
}

function today {
    Write-Host ""
    Write-YACentered "🪷 Today" $script:YA.Pink
    Write-YACentered "Date : $(Get-Date -Format 'dddd, MMMM dd, yyyy')" $script:YA.Soft
    Write-YACentered "Time : $(Get-Date -Format 'hh:mm tt')" $script:YA.Soft
    Write-YACentered "Path : $(Get-YAShortPath)" $script:YA.Soft
}

function breathe {
    Write-Host ""
    Write-YACentered "🧘 inhale..." $script:YA.Teal
    Start-Sleep -Milliseconds 700
    Write-YACentered "hold..." $script:YA.Gold
    Start-Sleep -Milliseconds 700
    Write-YACentered "exhale..." $script:YA.Green
    Start-Sleep -Milliseconds 900
    Write-YACentered "🪷 good. continue." $script:YA.Pink
}

function yogi-theme-info {
    Write-Host ""
    Write-YACentered "🪷 Yogi Artist Theme" $script:YA.Pink
    Write-YACentered "PowerShell : $($PSVersionTable.PSVersion)" $script:YA.Soft
    Write-YACentered "Edition    : $($PSVersionTable.PSEdition)" $script:YA.Soft
    Write-YACentered "Profile    : $PROFILE" $script:YA.Soft
    Write-YACentered "Path       : $(Get-YAShortPath)" $script:YA.Soft

    $branch = Get-YAGitBranch
    if ($branch) {
        Write-YACentered "Git        : $branch" $script:YA.Gold
    } else {
        Write-YACentered "Git        : not detected here" $script:YA.Gray
    }
}

function yrun {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Command
    )

    $cmd = $Command -join " "
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host ""
    Write-YACentered "╭──────────────────────────────────────────────╮" $script:YA.Gray
    Write-YACentered "│ 🎨 Running                                  │" $script:YA.Pink
    Write-YACentered "│ $cmd" $script:YA.Teal
    Write-YACentered "╰──────────────────────────────────────────────╯" $script:YA.Gray

    try {
        Invoke-Expression $cmd
        $exitCode = $LASTEXITCODE
        $sw.Stop()

        Write-Host ""
        Write-YACentered "╭──────────────────────────────────────────────╮" $script:YA.Gray

        if ($exitCode -eq 0 -or $null -eq $exitCode) {
            Write-YACentered "│ ✅ Done in $($sw.Elapsed.TotalSeconds.ToString('0.00'))s — the path is clear. │" $script:YA.Green
        } else {
            Write-YACentered "│ ⚠️ Exit $exitCode in $($sw.Elapsed.TotalSeconds.ToString('0.00'))s                         │" $script:YA.Gold
        }

        Write-YACentered "│ 🕉️  Breathe. Code. Repeat.                 │" $script:YA.Pink
        Write-YACentered "╰──────────────────────────────────────────────╯" $script:YA.Gray
    }
    catch {
        $sw.Stop()

        Write-Host ""
        Write-YACentered "╭──────────────────────────────────────────────╮" $script:YA.Gray
        Write-YACentered "│ 🔥 Error after $($sw.Elapsed.TotalSeconds.ToString('0.00'))s                    │" $script:YA.Red
        Write-YACentered "│ $($_.Exception.Message)" $script:YA.Red
        Write-YACentered "╰──────────────────────────────────────────────╯" $script:YA.Gray
    }
}

Set-Alias yr yrun

try {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
} catch {}

Write-YAStartupBanner
