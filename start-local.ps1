Write-Host "=== HyperMart Local Setup ===" -ForegroundColor Cyan

# Install frontend deps if needed
if (-not (Test-Path "frontend\node_modules")) {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    Set-Location frontend
    npm install
    Set-Location ..
}

# Install backend-node deps if needed
if (-not (Test-Path "backend-node\node_modules")) {
    Write-Host "Installing backend-node dependencies..." -ForegroundColor Yellow
    Set-Location backend-node
    npm install
    Set-Location ..
}

# Create backend .env if missing
if (-not (Test-Path "backend-node\.env")) {
    Write-Host "Creating backend .env..." -ForegroundColor Yellow
    @"
JWT_SECRET=hypermart-local-dev-secret-key
JWT_EXPIRY_DAYS=30
PORT=8000
NODE_ENV=development
MAX_UPLOAD_MB=10
"@ | Out-File -FilePath "backend-node\.env" -Encoding utf8
}

# Seed database if it doesn't exist
if (-not (Test-Path "backend-node\hypermart.db")) {
    Write-Host "Seeding database with demo data..." -ForegroundColor Yellow
    Set-Location backend-node
    node seed.js --reset
    Set-Location ..
}

# Start backend in new terminal
Write-Host "Starting backend on http://localhost:8000 ..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend-node'; node --watch index.js"

Start-Sleep -Seconds 2

# Start frontend in new terminal
Write-Host "Starting frontend on http://localhost:5173 ..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; npm run dev"

Write-Host ""
Write-Host "=== App starting up ===" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:5173" -ForegroundColor White
Write-Host "Backend:  http://localhost:8000" -ForegroundColor White
Write-Host "API Docs: http://localhost:8000/docs" -ForegroundColor White
Write-Host ""
Write-Host "Demo Credentials:" -ForegroundColor Yellow
Write-Host "  Customer : ravi@example.com   / Customer@123"
Write-Host "  Owner    : anand@example.com  / Owner@123"
Write-Host "  Admin    : senamallas@gmail.com / Admin@123"
