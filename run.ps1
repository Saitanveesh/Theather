$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Theatre Optical Security Lab" -ForegroundColor Cyan
Write-Host "Starting local research dashboards..." -ForegroundColor Gray
Write-Host ""

$python = Get-Command python -ErrorAction SilentlyContinue
$py = Get-Command py -ErrorAction SilentlyContinue

if (-not $python -and -not $py) {
    Write-Host "Python was not found in PATH." -ForegroundColor Red
    Write-Host "Install Python 3, reopen PowerShell, and run this script again."
    exit 1
}

$port = 8000

try {
    $existing = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Port $port is already in use." -ForegroundColor Yellow
        Write-Host "If the Theatre server is already running, opening the dashboards now."
    } else {
        if ($python) {
            Start-Process -FilePath "python" -ArgumentList "-m","http.server",$port -WorkingDirectory $PSScriptRoot
        } else {
            Start-Process -FilePath "py" -ArgumentList "-m","http.server",$port -WorkingDirectory $PSScriptRoot
        }
        Start-Sleep -Seconds 1
    }

    $sim = "http://localhost:$port/"
    $measured = "http://localhost:$port/measurement-dashboard.html"

    Start-Process $sim
    Start-Process $measured

    Write-Host "Simulator:            $sim" -ForegroundColor Green
    Write-Host "Measurement dashboard: $measured" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keep the Python server window/process running while using the dashboards." -ForegroundColor Gray
}
catch {
    Write-Host "Failed to start the local server: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
