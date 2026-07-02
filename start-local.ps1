Write-Host "=== HyperMart Local Setup ===" -ForegroundColor Cyan

# Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js is not installed. Download from https://nodejs.org" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Node.js $(node --version) found." -ForegroundColor Green

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
PORT=8000
NODE_ENV=development
MAX_UPLOAD_MB=10
"@ | Out-File -FilePath "$ROOT\backend-node\.env" -Encoding utf8

# Point frontend to local backend
"VITE_API_URL=http://localhost:8000" | Out-File -FilePath "$ROOT\frontend\.env" -Encoding utf8

# Seed database
if (-not (Test-Path "$ROOT\backend-node\hypermart.db")) {
    Write-Host "Seeding database..." -ForegroundColor Yellow
    Push-Location "$ROOT\backend-node"; node seed.js --reset; Pop-Location
}

# Start backend
Write-Host "Starting backend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'BACKEND' -ForegroundColor Cyan; cd '$ROOT\backend-node'; node index.js"

Start-Sleep -Seconds 3

# Start frontend
Write-Host "Starting frontend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'FRONTEND' -ForegroundColor Cyan; cd '$ROOT\frontend'; npm run dev"

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host " Frontend : http://localhost:5173" -ForegroundColor White
Write-Host " Backend  : http://localhost:8000" -ForegroundColor White
Write-Host " API Docs : http://localhost:8000/docs" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Demo Login:" -ForegroundColor Yellow
Write-Host "  Customer : ravi@example.com     / Customer@123"
Write-Host "  Owner    : anand@example.com    / Owner@123"
Write-Host "  Admin    : senamallas@gmail.com / Admin@123"
Write-Host ""
Write-Host "Opening browser in 5 seconds..." -ForegroundColor Green
Start-Sleep -Seconds 5
Start-Process "http://localhost:5173"
