param(
    [string]$Version = "latest"
)

# Configurazione
$IMAGE_NAME = "robbianco/robbiancoweb"

Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔍 Analyzing Flutter code..." -ForegroundColor Yellow
flutter analyze

Write-Host "🧪 Running Flutter tests..." -ForegroundColor Yellow
flutter test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Tests failed. Aborting build." -ForegroundColor Red
    exit 1
}

Write-Host "🏗️  Building Flutter Web locally (test)..." -ForegroundColor Yellow
flutter build web --release --web-renderer html

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter build failed. Aborting Docker build." -ForegroundColor Red
    exit 1
}

Write-Host "🐳 Building Docker image..." -ForegroundColor Yellow
docker build -t "${IMAGE_NAME}:${Version}" .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker build completed successfully!" -ForegroundColor Green
    
    # Tag latest se non è già latest
    if ($Version -ne "latest") {
        docker tag "${IMAGE_NAME}:${Version}" "${IMAGE_NAME}:latest"
        Write-Host "🏷️  Tagged as latest" -ForegroundColor Green
    }
    
    Write-Host "🧪 Testing Docker image locally..." -ForegroundColor Yellow
    docker run --rm -d -p 8080:80 --name flutter-test "${IMAGE_NAME}:${Version}"
    
    Start-Sleep -Seconds 5
    
    # Test health check
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Health check passed!" -ForegroundColor Green
            docker stop flutter-test
            
            Write-Host "📤 Pushing image to Docker Hub..." -ForegroundColor Yellow
            
            # Check login
            $dockerInfo = docker info 2>$null
            if (-not ($dockerInfo -like "*Username*")) {
                Write-Host "🔐 Please login to Docker Hub:" -ForegroundColor Yellow
                docker login
            }
            
            # Push dell'immagine
            docker push "${IMAGE_NAME}:${Version}"
            
            if ($Version -ne "latest") {
                docker push "${IMAGE_NAME}:latest"
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Push completed successfully!" -ForegroundColor Green
                Write-Host "🌐 Image available at: ${IMAGE_NAME}:${Version}" -ForegroundColor Green
                Write-Host ""
                Write-Host "🚀 To deploy on server, run:" -ForegroundColor Cyan
                Write-Host "   docker-compose pull fe" -ForegroundColor White
                Write-Host "   docker-compose up -d fe" -ForegroundColor White
            } else {
                Write-Host "❌ Error during push" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "❌ Health check failed - HTTP Status: $($response.StatusCode)" -ForegroundColor Red
            docker stop flutter-test
            exit 1
        }
    } catch {
        Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
        docker stop flutter-test
        exit 1
    }
} else {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}