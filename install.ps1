Param(
    [Alias("i")][switch]$Install,
    [Alias("u")][switch]$Update
)

function Show-Usage {
    Write-Host "Usage: .\nvim-fzf.ps1 [-Install] [-Update]"
    Write-Host "  -Install   Run interactive installation"
    Write-Host "  -Update    Update Neovim, fzf, and PSFzf silently"
    exit 1
}

if (-not ($Install -or $Update)) {
    Show-Usage
}

function Confirm-Action($Message) {
    $response = Read-Host "$Message ([Y]/n)"
    return ($response -eq '' -or $response -match '^[Yy]$')
}

function Install-System-Packages {
    Write-Host "Installing system packages..."

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Please install winget manually."
        exit 1
    }

    $packages = @(
        @{ Name = "Git"; Id = "Git.Git" },
        @{ Name = "ripgrep"; Id = "BurntSushi.ripgrep.MSVC" },
        @{ Name = "MSYS2"; Id = "MSYS2.MSYS2" }
        @{ Name = "zig"; Id = "zig.zig" }
    )

    foreach ($pkg in $packages) {
        Write-Host "Installing $($pkg.Name)..."
        winget install -e --id $($pkg.Id) --silent
    }
}

function Add-Msys2ToUserPath {
    $msys2Root = "C:\msys64"
    $msys2Bin = Join-Path $msys2Root "usr\bin"

    # Get current user PATH from registry
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $paths = $userPath -split ';'

    $changed = $false

    if (-not ($paths -contains $msys2Root)) {
        $userPath += ";$msys2Root"
        $changed = $true
        Write-Host "Adding MSYS2 root to user PATH."
    }

    if (-not ($paths -contains $msys2Bin)) {
        $userPath += ";$msys2Bin"
        $changed = $true
        Write-Host "Adding MSYS2 usr/bin to user PATH."
    }

    if ($changed) {
        [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
        Write-Host "User PATH environment variable updated. Restart your terminal or log off/on for changes to take effect."
    } else {
        Write-Host "MSYS2 paths already exist in user PATH."
    }
}

function Install-GCC-With-MSYS2 {
    $msys2Bash = "C:\msys64\usr\bin\bash.exe"

    if (-not (Test-Path $msys2Bash)) {
        Write-Host "MSYS2 bash not found at $msys2Bash. Skipping gcc installation."
        return
    }

    Write-Host "Updating MSYS2 and installing gcc package via pacman..."

    try {
        & $msys2Bash -lc "pacman -Syu --noconfirm"
        & $msys2Bash -lc "pacman -S --noconfirm gcc"
        Write-Host "gcc installed successfully via MSYS2."
    } catch {
        Write-Host "Failed to install gcc via MSYS2: $_"
    }
}

function Install-Or-Update-Neovim {
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        if ($Install) {
            if (-not (Confirm-Action "Neovim is already installed. Reinstall/Update?")) {
                Write-Host "Skipping Neovim installation."
                return
            }
        }
    }

    Write-Host "Installing/Updating Neovim..."
    winget install --id=Neovim.Neovim -e --silent
    Write-Host "Neovim installed/updated successfully."
}

function Install-Or-Update-Fzf {
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        if ($Install) {
            if (-not (Confirm-Action "fzf is already installed. Reinstall/Update?")) {
                Write-Host "Skipping fzf installation."
                return
            }
        }
    }

    Write-Host "Installing/Updating fzf..."
    winget install --id=junegunn.fzf -e --silent
    Write-Host "fzf installed/updated successfully."
}

function Install-Or-Update-PSFzf {
    if (Get-Module -ListAvailable -Name PSFzf) {
        if ($Install) {
            if (-not (Confirm-Action "PSFzf module is already installed. Reinstall/Update?")) {
                Write-Host "Skipping PSFzf installation."
                return
            }
        }
    }

    Write-Host "Installing/Updating PSFzf module..."
    try {
        Install-Module -Name PSFzf -Scope CurrentUser -Force -AllowClobber
        Write-Host "PSFzf module installed/updated successfully."
    } catch {
        Write-Host "Failed to install PSFzf module: $_"
    }
}

# Main Execution Flow

if ($Install) {
    Install-System-Packages

    if (Test-Path "C:\msys64") {
        Add-Msys2ToUserPath

        # Also update session PATH so this script can use gcc immediately
        $msys2Root = "C:\msys64"
        $msys2Bin = Join-Path $msys2Root "usr\bin"

        if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $msys2Root })) {
            $env:PATH = "$env:PATH;$msys2Root"
        }
        if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $msys2Bin })) {
            $env:PATH = "$env:PATH;$msys2Bin"
        }

        Write-Host "Added MSYS2 to PATH for current session."

        Install-GCC-With-MSYS2
    } else {
        Write-Host "MSYS2 directory not found, skipping gcc installation."
    }

    if (Confirm-Action "Install Neovim?") {
        Install-Or-Update-Neovim
    }

    if (Confirm-Action "Install fzf?") {
        Install-Or-Update-Fzf
    }

    if (Confirm-Action "Install PSFzf PowerShell module?") {
        Install-Or-Update-PSFzf
    }
}
elseif ($Update) {
    Install-Or-Update-Neovim
    Install-Or-Update-Fzf
    Install-Or-Update-PSFzf
}

Write-Host "Done."

