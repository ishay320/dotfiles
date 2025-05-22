# Define source and target paths
$src = Join-Path -Path $PSScriptRoot -ChildPath "nvim"
$dst = "$env:USERPROFILE\AppData\Local\nvim"

# Remove existing Neovim config (directory or symlink)
if (Test-Path $dst) {
    Write-Host "Removing existing Neovim config at $dst"
    Remove-Item -Recurse -Force $dst
}

# Create symbolic link
Write-Host "Creating symbolic link from:"
Write-Host "  $src"
Write-Host "    to"
Write-Host "  $dst"
New-Item -ItemType SymbolicLink -Path $dst -Target $src

Write-Host "Done."

