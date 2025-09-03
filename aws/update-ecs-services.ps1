# Script de mise à jour des services ECS avec les nouvelles images
# Utilisation: .\update-ecs-services.ps1 -Environment production -Region us-east-1 -ImageTag latest

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

Write-Host "🔄 Mise à jour des services ECS..." -ForegroundColor Green
Write-Host "Environnement: $Environment" -ForegroundColor Yellow
Write-Host "Région: $Region" -ForegroundColor Yellow
Write-Host "Tag d'image: $ImageTag" -ForegroundColor Yellow

# Récupérer les informations de la stack CloudFormation
Write-Host "🔍 Récupération des informations de la stack..." -ForegroundColor Blue
try {
    $stackOutputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].Outputs' | ConvertFrom-Json
    
    if (-not $stackOutputs) {
        throw "Impossible de récupérer les outputs de la stack"
    }
    
    $ecsClusterName = $stackOutputs | Where-Object { $_.OutputKey -eq "ECSClusterName" }
    $backendEcrUri = $stackOutputs | Where-Object { $_.OutputKey -eq "BackendECRRepositoryUri" }
    $frontendEcrUri = $stackOutputs | Where-Object { $_.OutputKey -eq "FrontendECRRepositoryUri" }
    
    if (-not $ecsClusterName -or -not $backendEcrUri -or -not $frontendEcrUri) {
        throw "Impossible de récupérer les informations ECS/ECR depuis la stack"
    }
    
    Write-Host "✅ Informations récupérées:" -ForegroundColor Green
    Write-Host "   Cluster ECS: $($ecsClusterName.OutputValue)" -ForegroundColor Cyan
    Write-Host "   Backend ECR: $($backendEcrUri.OutputValue)" -ForegroundColor Cyan
    Write-Host "   Frontend ECR: $($frontendEcrUri.OutputValue)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erreur lors de la récupération des informations de la stack: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vérifiez que la stack '$StackName' existe et est déployée avec succès" -ForegroundColor Yellow
    exit 1
}

# Fonction pour mettre à jour un service ECS
function UpdateECSService {
    param(
        [string]$ServiceName,
        [string]$ImageUri
    )
    
    Write-Host "`n🔄 Mise à jour du service $ServiceName..." -ForegroundColor Blue
    
    # Récupérer la définition de tâche actuelle
    Write-Host "   Récupération de la définition de tâche actuelle..." -ForegroundColor Yellow
    $taskDefinition = aws ecs describe-task-definition --task-definition $ServiceName --region $Region | ConvertFrom-Json
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Impossible de récupérer la définition de tâche pour $ServiceName" -ForegroundColor Red
        return $false
    }
    
    # Créer une nouvelle définition de tâche avec la nouvelle image
    $newTaskDef = $taskDefinition.taskDefinition
    $newTaskDef.containerDefinitions[0].image = "$ImageUri`:$ImageTag"
    
    # Supprimer les champs qui ne peuvent pas être modifiés
    $newTaskDef.PSObject.Properties.Remove('taskDefinitionArn')
    $newTaskDef.PSObject.Properties.Remove('revision')
    $newTaskDef.PSObject.Properties.Remove('status')
    $newTaskDef.PSObject.Properties.Remove('requiresAttributes')
    $newTaskDef.PSObject.Properties.Remove('placementConstraints')
    $newTaskDef.PSObject.Properties.Remove('compatibilities')
    $newTaskDef.PSObject.Properties.Remove('registeredAt')
    $newTaskDef.PSObject.Properties.Remove('registeredBy')
    
    # Créer un fichier temporaire pour la nouvelle définition
    $tempFile = "temp-task-def-$ServiceName.json"
    $newTaskDef | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempFile -Encoding UTF8
    
    try {
        # Enregistrer la nouvelle définition de tâche
        Write-Host "   Enregistrement de la nouvelle définition de tâche..." -ForegroundColor Yellow
        $newTaskDefArn = aws ecs register-task-definition --cli-input-json file://$tempFile --region $Region --query 'taskDefinition.taskDefinitionArn' --output text
        
        if ($LASTEXITCODE -ne 0) {
            throw "Échec de l'enregistrement de la nouvelle définition de tâche"
        }
        
        Write-Host "   ✅ Nouvelle définition de tâche enregistrée: $newTaskDefArn" -ForegroundColor Green
        
        # Mettre à jour le service
        Write-Host "   Mise à jour du service..." -ForegroundColor Yellow
        aws ecs update-service --cluster $ecsClusterName.OutputValue --service $ServiceName --task-definition $newTaskDefArn --region $Region | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Échec de la mise à jour du service"
        }
        
        Write-Host "   ✅ Service $ServiceName mis à jour avec succès" -ForegroundColor Green
        
        # Attendre que le service soit stable
        Write-Host "   ⏳ Attente de la stabilisation du service..." -ForegroundColor Yellow
        aws ecs wait services-stable --cluster $ecsClusterName.OutputValue --services $ServiceName --region $Region
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Service $ServiceName est stable" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Service $ServiceName pourrait ne pas être stable" -ForegroundColor Yellow
        }
        
        return $true
        
    } catch {
        Write-Host "❌ Erreur lors de la mise à jour du service $ServiceName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        # Nettoyer le fichier temporaire
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
    }
}

# Mettre à jour le service backend
$backendServiceName = "$Environment-flighthub-backend"
$backendSuccess = UpdateECSService -ServiceName $backendServiceName -ImageUri $backendEcrUri.OutputValue

# Mettre à jour le service frontend
$frontendServiceName = "$Environment-flighthub-frontend"
$frontendSuccess = UpdateECSService -ServiceName $frontendServiceName -ImageUri $frontendEcrUri.OutputValue

# Résumé
Write-Host "`n📊 Résumé des mises à jour:" -ForegroundColor Green
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
    Write-Host "1. Vérifier la santé des services" -ForegroundColor White
    Write-Host "2. Tester l'application" -ForegroundColor White
    Write-Host "3. Surveiller les logs CloudWatch" -ForegroundColor White
    
    Write-Host "`n🔍 Vérification de la santé des services:" -ForegroundColor Green
    Write-Host "   aws ecs describe-services --cluster $($ecsClusterName.OutputValue) --services $backendServiceName $frontendServiceName --region $Region" -ForegroundColor Gray
    
    Write-Host "`n📋 Logs des services:" -ForegroundColor Green
    Write-Host "   Backend: /ecs/$Environment-flighthub-backend" -ForegroundColor Cyan
    Write-Host "   Frontend: /ecs/$Environment-flighthub-frontend" -ForegroundColor Cyan
    
    Write-Host "`n✅ Mise à jour des services terminée avec succès!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Certains services n'ont pas pu être mis à jour" -ForegroundColor Red
    exit 1
}


