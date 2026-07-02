$ErrorActionPreference = "Stop"
$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== HyperMart ===" -ForegroundColor Cyan
Write-Host "Root: $ROOT"

# Check Node
try { $v = node --version; Write-Host "Node $v" -ForegroundColor Green }
catch { Write-Host "ERROR: Node.js not installed. Get it: https://nodejs.org" -ForegroundColor Red; Read-Host; exit }

# Write backend .env
Set-Content "$ROOT\backend-node\.env" "JWT_SECRET=hypermart-secret`nJWT_EXPIRY_DAYS=30`nPORT=5000`nNODE_ENV=development`nMAX_UPLOAD_MB=10"
Write-Host ".env written"

# Install backend deps
Write-Host "Installing backend deps..." -ForegroundColor Yellow
Set-Location "$ROOT\backend-node"
npm install
if ($LASTEXITCODE -ne 0) { Write-Host "npm install FAILED" -ForegroundColor Red; Read-Host; exit }
Write-Host "Deps installed" -ForegroundColor Green

# Seed
if (-not (Test-Path "$ROOT\backend-node\hypermart.db")) {
    Write-Host "Seeding..." -ForegroundColor Yellow
    node seed.js --reset
    if ($LASTEXITCODE -ne 0) { Write-Host "Seed FAILED" -ForegroundColor Red; Read-Host; exit }
    Write-Host "Seeded" -ForegroundColor Green
}

Write-Host ""
Write-Host "Open http://localhost:5000 in your browser" -ForegroundColor Cyan
Write-Host "Customer: ravi@example.com / Customer@123"
Write-Host ""
Write-Host "Starting server..." -ForegroundColor Green

Set-Location "$ROOT\backend-node"
node index.js
