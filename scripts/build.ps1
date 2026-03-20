param(
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$VenvPath = Join-Path $RepoRoot ".venv"
$PythonExe = Join-Path $VenvPath "Scripts\\python.exe"
$TmpPath = Join-Path $RepoRoot ".tmp"

Write-Host "Repo: $RepoRoot"

# Ensure a writable temp directory for pip/build operations
if (-not (Test-Path $TmpPath)) {
    New-Item -ItemType Directory -Path $TmpPath | Out-Null
}
$env:TEMP = $TmpPath
$env:TMP = $TmpPath

if ($Clean) {
    Write-Host "Cleaning build artifacts..."
    foreach ($path in @("dist", "build")) {
        $full = Join-Path $RepoRoot $path
        if (Test-Path $full) {
            Remove-Item -Recurse -Force $full
        }
    }
    Get-ChildItem -Path $RepoRoot -Filter "*.egg-info" -Directory | ForEach-Object {
        Remove-Item -Recurse -Force $_.FullName
    }
}

if (-not (Test-Path $PythonExe)) {
    Write-Host "Creating virtual environment..."
    python -m venv $VenvPath
}

Write-Host "Installing build tooling..."
& $PythonExe -m pip install -U pip build

Write-Host "Building sdist and wheel..."
Push-Location $RepoRoot
try {
    & $PythonExe -m build
}
finally {
    Pop-Location
}

Write-Host "Done. Artifacts are in dist\\"
