Write-Host "=== HyperMart Local Setup ===" -ForegroundColor Cyan

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js not installed. Get it from https://nodejs.org" -ForegroundColor Red
    pause; exit 1
}
Write-Host "Node $(node --version) found." -ForegroundColor Green

$ROOT = $PSScriptRoot

# Install backend deps
if (-not (Test-Path "$ROOT\backend-node\node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    Push-Location "$ROOT\backend-node"; npm install; Pop-Location
}

# Create backend .env
@"
JWT_SECRET=hypermart-local-dev-secret-key
JWT_EXPIRY_DAYS=30
PORT=3001
NODE_ENV=development
MAX_UPLOAD_MB=10
"@ | Out-File -FilePath "$ROOT\backend-node\.env" -Encoding utf8

# Seed database
if (-not (Test-Path "$ROOT\backend-node\hypermart.db")) {
    Write-Host "Seeding database..." -ForegroundColor Yellow
    Push-Location "$ROOT\backend-node"; node seed.js --reset; Pop-Location
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host " Open: http://localhost:3001    " -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host " Customer : ravi@example.com / Customer@123"
Write-Host " Owner    : anand@example.com / Owner@123"
Write-Host " Admin    : senamallas@gmail.com / Admin@123"
Write-Host ""

Push-Location "$ROOT\backend-node"; node index.js
