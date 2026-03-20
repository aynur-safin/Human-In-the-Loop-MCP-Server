Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$VenvPath = Join-Path $RepoRoot ".venv"
$PythonExe = Join-Path $VenvPath "Scripts\\python.exe"
$TmpPath = Join-Path $RepoRoot ".tmp"

Write-Host "Repo: $RepoRoot"

# Ensure a writable temp directory for pip operations
if (-not (Test-Path $TmpPath)) {
    New-Item -ItemType Directory -Path $TmpPath | Out-Null
}
$env:TEMP = $TmpPath
$env:TMP = $TmpPath

if (-not (Test-Path $PythonExe)) {
    Write-Host "Creating virtual environment..."
    python -m venv $VenvPath
}

Write-Host "Upgrading pip..."
& $PythonExe -m pip install -U pip

Write-Host "Installing project in editable mode..."
Push-Location $RepoRoot
try {
    & $PythonExe -m pip install -e .
}
finally {
    Pop-Location
}

Write-Host "Done. Editable install is ready."
