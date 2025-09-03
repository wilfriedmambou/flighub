# Script de build et push des images Docker vers ECR
# Utilisation: .\build-and-push-images.ps1 -Environment production -Region us-east-1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$StackName = "flighthub-stack",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest"
)

Write-Host "🐳 Build et push des images Docker vers ECR..." -ForegroundColor Green
Write-Host "Environnement: $Environment" -ForegroundColor Yellow
Write-Host "Région: $Region" -ForegroundColor Yellow
Write-Host "Tag d'image: $ImageTag" -ForegroundColor Yellow

# Vérifier que Docker est installé
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker non trouvé"
    }
    Write-Host "✅ Docker détecté: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "Veuillez installer Docker Desktop depuis: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Vérifier que Docker est en cours d'exécution
try {
    docker info 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker n'est pas en cours d'exécution"
    }
    Write-Host "✅ Docker est en cours d'exécution" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas en cours d'exécution. Démarrez Docker Desktop" -ForegroundColor Red
    exit 1
}

# Récupérer les informations de la stack CloudFormation
Write-Host "🔍 Récupération des informations de la stack..." -ForegroundColor Blue
try {
    $stackOutputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].Outputs' | ConvertFrom-Json
    
    if (-not $stackOutputs) {
        throw "Impossible de récupérer les outputs de la stack"
    }
    
    $backendEcrUri = $stackOutputs | Where-Object { $_.OutputKey -eq "BackendECRRepositoryUri" }
    $frontendEcrUri = $stackOutputs | Where-Object { $_.OutputKey -eq "FrontendECRRepositoryUri" }
    
    if (-not $backendEcrUri -or -not $frontendEcrUri) {
        throw "Impossible de récupérer les URIs ECR depuis la stack"
    }
    
    Write-Host "✅ URIs ECR récupérés:" -ForegroundColor Green
    Write-Host "   Backend: $($backendEcrUri.OutputValue)" -ForegroundColor Cyan
    Write-Host "   Frontend: $($frontendEcrUri.OutputValue)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erreur lors de la récupération des informations de la stack: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vérifiez que la stack '$StackName' existe et est déployée avec succès" -ForegroundColor Yellow
    exit 1
}

# Se connecter à ECR
Write-Host "🔐 Connexion à ECR..." -ForegroundColor Blue
try {
    $ecrLogin = aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $($backendEcrUri.OutputValue.Split('/')[0])
    
    if ($LASTEXITCODE -ne 0) {
        throw "Échec de la connexion à ECR"
    }
    
    Write-Host "✅ Connecté à ECR avec succès" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de connexion à ECR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Fonction pour construire et pousser une image
function BuildAndPushImage {
    param(
        [string]$ServiceName,
        [string]$EcrUri,
        [string]$DockerfilePath,
        [string]$BuildContext
    )
    
    Write-Host "`n🔨 Construction de l'image $ServiceName..." -ForegroundColor Blue
    
    # Construire l'image
    $imageName = "$EcrUri`:$ImageTag"
    Write-Host "   Image: $imageName" -ForegroundColor Gray
    
    # Vérifier que le Dockerfile existe
    if (-not (Test-Path $DockerfilePath)) {
        Write-Host "❌ Dockerfile non trouvé: $DockerfilePath" -ForegroundColor Red
        return $false
    }
    
    # Construire l'image
    Write-Host "   Construction en cours..." -ForegroundColor Yellow
    docker build -t $imageName -f $DockerfilePath $BuildContext
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Échec de la construction de l'image $ServiceName" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ Image $ServiceName construite avec succès" -ForegroundColor Green
    
    # Pousser l'image vers ECR
    Write-Host "📤 Push de l'image $ServiceName vers ECR..." -ForegroundColor Blue
    docker push $imageName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Échec du push de l'image $ServiceName" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ Image $ServiceName poussée avec succès vers ECR" -ForegroundColor Green
    return $true
}

# Construire et pousser l'image backend
$backendSuccess = BuildAndPushImage -ServiceName "Backend" -EcrUri $backendEcrUri.OutputValue -DockerfilePath "../backend/Dockerfile" -BuildContext "../backend"

# Construire et pousser l'image frontend
$frontendSuccess = BuildAndPushImage -ServiceName "Frontend" -EcrUri $frontendEcrUri.OutputValue -DockerfilePath "../frontend/Dockerfile" -BuildContext "../frontend"

# Résumé
Write-Host "`n📊 Résumé du build et push:" -ForegroundColor Green
if ($backendSuccess) {
    Write-Host "✅ Backend: Succès" -ForegroundColor Green
} else {
    Write-Host "❌ Backend: Échec" -ForegroundColor Red
}

if ($frontendSuccess) {
    Write-Host "✅ Frontend: Succès" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend: Échec" -ForegroundColor Red
}

if ($backendSuccess -and $frontendSuccess) {
    Write-Host "`n🎯 Prochaines étapes:" -ForegroundColor Green
    Write-Host "1. Mettre à jour les services ECS avec les nouvelles images" -ForegroundColor White
    Write-Host "2. Vérifier la santé des services" -ForegroundColor White
    Write-Host "3. Tester l'application" -ForegroundColor White
    
    Write-Host "`n🔗 URLs des images ECR:" -ForegroundColor Green
    Write-Host "   Backend: $($backendEcrUri.OutputValue):$ImageTag" -ForegroundColor Cyan
    Write-Host "   Frontend: $($frontendEcrUri.OutputValue):$ImageTag" -ForegroundColor Cyan
    
    Write-Host "`n✅ Build et push terminés avec succès!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Certaines images n'ont pas pu être construites ou poussées" -ForegroundColor Red
    exit 1
}


