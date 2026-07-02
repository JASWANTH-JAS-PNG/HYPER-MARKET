Write-Host "=== HyperMart Local Setup ===" -ForegroundColor Cyan

# Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js not installed. Get it from https://nodejs.org" -ForegroundColor Red
    pause; exit 1
}
Write-Host "Node $(node --version) found." -ForegroundColor Green

$ROOT = $PSScriptRoot

# Install backend deps
if (-not (Test-Path "$ROOT\backend-node\node_modules")) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    Push-Location "$ROOT\backend-node"; npm install; Pop-Location
}

# Install frontend deps
if (-not (Test-Path "$ROOT\frontend\node_modules")) {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    Push-Location "$ROOT\frontend"; npm install; Pop-Location
}

# Create backend .env
@"
JWT_SECRET=hypermart-local-dev-secret-key
JWT_EXPIRY_DAYS=30
PORT=3001
NODE_ENV=development
MAX_UPLOAD_MB=10
"@ | Out-File -FilePath "$ROOT\backend-node\.env" -Encoding utf8

# Build frontend pointing to backend port 3001
Write-Host "Building frontend..." -ForegroundColor Yellow
"VITE_API_URL=http://localhost:3001" | Out-File -FilePath "$ROOT\frontend\.env" -Encoding utf8
Push-Location "$ROOT\frontend"; npm run build; Pop-Location

# Seed database
if (-not (Test-Path "$ROOT\backend-node\hypermart.db")) {
    Write-Host "Seeding database..." -ForegroundColor Yellow
    Push-Location "$ROOT\backend-node"; node seed.js --reset; Pop-Location
}

# Start single server (serves API + built frontend)
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host " Starting HyperMart..." -ForegroundColor Green
Write-Host " Open: http://localhost:3001" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Demo Login:" -ForegroundColor Yellow
Write-Host "  Customer : ravi@example.com     / Customer@123"
Write-Host "  Owner    : anand@example.com    / Owner@123"
Write-Host "  Admin    : senamallas@gmail.com / Admin@123"
Write-Host ""

Push-Location "$ROOT\backend-node"; node index.js
