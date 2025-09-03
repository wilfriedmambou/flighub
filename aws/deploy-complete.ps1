# Script principal de déploiement complet FlightHub sur AWS
# Utilisation: .\deploy-complete.ps1 -Environment production -DatabasePassword "VotreMotDePasse" -Region us-east-1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$true)]
    [string]$DatabasePassword,
    
    [Parameter(Mandatory=$false)]
    [string]$StackName = "flighthub-stack",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipInfrastructure,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipDeploy,
    
    [Parameter(Mandatory=$false)]
    [switch]$HealthCheck
)

Write-Host "🚀 Déploiement complet FlightHub sur AWS" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Environnement: $Environment" -ForegroundColor Yellow
Write-Host "Région: $Region" -ForegroundColor Yellow
Write-Host "Nom de la stack: $StackName" -ForegroundColor Yellow
Write-Host "Tag d'image: $ImageTag" -ForegroundColor Yellow

if ($SkipInfrastructure) { Write-Host "⚠️  Infrastructure: Ignoré" -ForegroundColor Yellow }
if ($SkipBuild) { Write-Host "⚠️  Build: Ignoré" -ForegroundColor Yellow }
if ($SkipDeploy) { Write-Host "⚠️  Déploiement: Ignoré" -ForegroundColor Yellow }
if ($HealthCheck) { Write-Host "🏥  Health Check: Activé" -ForegroundColor Green }

Write-Host ""

# Fonction pour exécuter une étape avec gestion d'erreur
function ExecuteStep {
    param(
        [string]$StepName,
        [string]$Command,
        [string]$ErrorMessage
    )
    
    Write-Host "🔄 $StepName..." -ForegroundColor Blue
    Write-Host "   Commande: $Command" -ForegroundColor Gray
    
    try {
        Invoke-Expression $Command
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ $StepName terminé avec succès" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ $StepName a échoué (code: $LASTEXITCODE)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Erreur lors de $StepName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Étape 1: Déploiement de l'infrastructure (si non ignorée)
if (-not $SkipInfrastructure) {
    Write-Host "`n🏗️  ÉTAPE 1: Déploiement de l'infrastructure" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    
    $infraSuccess = ExecuteStep -StepName "Déploiement de la stack CloudFormation" -Command ".\deploy-stack.ps1 -Environment $Environment -DatabasePassword '$DatabasePassword' -StackName $StackName -Region $Region" -ErrorMessage "Échec du déploiement de l'infrastructure"
    
    if (-not $infraSuccess) {
        Write-Host "`n❌ Déploiement de l'infrastructure échoué. Arrêt du processus." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n⏳ Attente de 30 secondes pour la stabilisation de l'infrastructure..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
} else {
    Write-Host "`n⏭️  ÉTAPE 1: Infrastructure ignorée" -ForegroundColor Yellow
}

# Étape 2: Build et push des images Docker (si non ignoré)
if (-not $SkipBuild) {
    Write-Host "`n🐳 ÉTAPE 2: Build et push des images Docker" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    
    $buildSuccess = ExecuteStep -StepName "Build et push des images" -Command ".\build-and-push-images.ps1 -Environment $Environment -Region $Region -StackName $StackName -ImageTag $ImageTag" -ErrorMessage "Échec du build et push des images"
    
    if (-not $buildSuccess) {
        Write-Host "`n❌ Build et push des images échoué. Arrêt du processus." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n⏳ Attente de 15 secondes pour la finalisation du push..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
} else {
    Write-Host "`n⏭️  ÉTAPE 2: Build ignoré" -ForegroundColor Yellow
}

# Étape 3: Mise à jour des services ECS (si non ignoré)
if (-not $SkipDeploy) {
    Write-Host "`n🔄 ÉTAPE 3: Mise à jour des services ECS" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    
    $deploySuccess = ExecuteStep -StepName "Mise à jour des services ECS" -Command ".\update-ecs-services.ps1 -Environment $Environment -Region $Region -StackName $StackName -ImageTag $ImageTag" -ErrorMessage "Échec de la mise à jour des services ECS"
    
    if (-not $deploySuccess) {
        Write-Host "`n❌ Mise à jour des services ECS échouée. Arrêt du processus." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n⏳ Attente de 60 secondes pour la stabilisation des services..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
} else {
    Write-Host "`n⏭️  ÉTAPE 3: Déploiement ignoré" -ForegroundColor Yellow
}

# Étape 4: Vérification de la santé (si demandée)
if ($HealthCheck) {
    Write-Host "`n🏥 ÉTAPE 4: Vérification de la santé des services" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    
    $healthSuccess = ExecuteStep -StepName "Vérification de la santé" -Command ".\check-services-health.ps1 -Environment $Environment -Region $Region -StackName $StackName" -ErrorMessage "Échec de la vérification de la santé"
    
    if (-not $healthSuccess) {
        Write-Host "`n⚠️  Vérification de la santé échouée, mais le déploiement peut continuer" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n⏭️  ÉTAPE 4: Health Check ignoré" -ForegroundColor Yellow
}

# Récupération des informations finales
Write-Host "`n📊 RÉSUMÉ FINAL" -ForegroundColor Magenta
Write-Host "===============================================" -ForegroundColor Magenta

try {
    $stackOutputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].Outputs' | ConvertFrom-Json
    
    if ($stackOutputs) {
        Write-Host "✅ Infrastructure déployée avec succès!" -ForegroundColor Green
        
        $frontendAlb = $stackOutputs | Where-Object { $_.OutputKey -eq "FrontendALBDNSName" }
        $backendAlb = $stackOutputs | Where-Object { $_.OutputKey -eq "BackendALBDNSName" }
        
        Write-Host "`n🔗 URLs d'accès:" -ForegroundColor Green
        if ($frontendAlb) {
            Write-Host "   Frontend: http://$($frontendAlb.OutputValue)" -ForegroundColor Cyan
        }
        if ($backendAlb) {
            Write-Host "   Backend API: http://$($backendAlb.OutputValue)" -ForegroundColor Cyan
            Write-Host "   Documentation Swagger: http://$($backendAlb.OutputValue)/api/docs" -ForegroundColor Cyan
        }
        
        Write-Host "`n🎯 Prochaines étapes:" -ForegroundColor Green
        Write-Host "1. Tester l'application via les URLs ci-dessus" -ForegroundColor White
        Write-Host "2. Vérifier la documentation Swagger" -ForegroundColor White
        Write-Host "3. Surveiller les logs CloudWatch" -ForegroundColor White
        Write-Host "4. Configurer un domaine personnalisé si nécessaire" -ForegroundColor White
        
        Write-Host "`n🔍 Commandes de monitoring:" -ForegroundColor Yellow
        Write-Host "   Vérifier la santé: .\check-services-health.ps1 -Environment $Environment -Region $Region" -ForegroundColor Gray
        Write-Host "   Logs backend: aws logs tail /ecs/$Environment-flighthub-backend --region $Region" -ForegroundColor Gray
        Write-Host "   Logs frontend: aws logs tail /ecs/$Environment-flighthub-frontend --region $Region" -ForegroundColor Gray
        
    } else {
        Write-Host "⚠️  Impossible de récupérer les informations de la stack" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Erreur lors de la récupération des informations finales: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n🎉 DÉPLOIEMENT COMPLET TERMINÉ!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

if ($HealthCheck) {
    Write-Host "🏥 Vérifiez la santé des services avec: .\check-services-health.ps1 -Environment $Environment -Region $Region" -ForegroundColor Cyan
}

Write-Host "`n📚 Documentation et support:" -ForegroundColor Blue
Write-Host "   AWS ECS: https://docs.aws.amazon.com/ecs/" -ForegroundColor Gray
Write-Host "   AWS RDS: https://docs.aws.amazon.com/rds/" -ForegroundColor Gray
Write-Host "   AWS ECR: https://docs.aws.amazon.com/ecr/" -ForegroundColor Gray
Write-Host "   CloudFormation: https://docs.aws.amazon.com/cloudformation/" -ForegroundColor Gray


