<#
  start-dev.ps1
  Usage: run this after you start XAMPP (MySQL). The script waits until MySQL port 3306 is reachable,
  then runs `npm run dev` (which starts backend and frontend via concurrently).

  Open PowerShell as administrator if needed and run:
    .\start-dev.ps1
#>

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Project root: $projectRoot"

function Test-PortOpen($host, $port) {
  try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $async = $tcp.BeginConnect($host, $port, $null, $null)
    $wait = $async.AsyncWaitHandle.WaitOne(300)
    if (-not $wait) { $tcp.Close(); return $false }
    $tcp.EndConnect($async)
    $tcp.Close()
    return $true
  } catch {
    return $false
  }
}

$host = '127.0.0.1'
$port = 3306
$tries = 0
Write-Host "Waiting for MySQL on $host:$port (XAMPP)..."
while (-not (Test-PortOpen $host $port)) {
  $tries++
  if ($tries -gt 120) {
    Write-Host "Timed out waiting for MySQL on $host:$port. Please ensure XAMPP MySQL is running." -ForegroundColor Red
    exit 1
  }
  Start-Sleep -Seconds 1
}
Write-Host "MySQL is reachable. Starting dev servers..." -ForegroundColor Green

Set-Location $projectRoot
npm run dev
