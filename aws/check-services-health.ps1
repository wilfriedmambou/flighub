# Script de vérification de la santé des services FlightHub
# Utilisation: .\check-services-health.ps1 -Environment production -Region us-east-1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$StackName = "flighthub-stack"
)

Write-Host "🏥 Vérification de la santé des services FlightHub..." -ForegroundColor Green
Write-Host "Environnement: $Environment" -ForegroundColor Yellow
Write-Host "Région: $Region" -ForegroundColor Yellow

# Récupérer les informations de la stack CloudFormation
Write-Host "🔍 Récupération des informations de la stack..." -ForegroundColor Blue
try {
    $stackOutputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].Outputs' | ConvertFrom-Json
    
    if (-not $stackOutputs) {
        throw "Impossible de récupérer les outputs de la stack"
    }
    
    $ecsClusterName = $stackOutputs | Where-Object { $_.OutputKey -eq "ECSClusterName" }
    $backendAlbDns = $stackOutputs | Where-Object { $_.OutputKey -eq "BackendALBDNSName" }
    $frontendAlbDns = $stackOutputs | Where-Object { $_.OutputKey -eq "FrontendALBDNSName" }
    $databaseEndpoint = $stackOutputs | Where-Object { $_.OutputKey -eq "DatabaseEndpoint" }
    
    if (-not $ecsClusterName) {
        throw "Impossible de récupérer le nom du cluster ECS"
    }
    
    Write-Host "✅ Informations récupérées:" -ForegroundColor Green
    Write-Host "   Cluster ECS: $($ecsClusterName.OutputValue)" -ForegroundColor Cyan
    if ($backendAlbDns) { Write-Host "   Backend ALB: $($backendAlbDns.OutputValue)" -ForegroundColor Cyan }
    if ($frontendAlbDns) { Write-Host "   Frontend ALB: $($frontendAlbDns.OutputValue)" -ForegroundColor Cyan }
    if ($databaseEndpoint) { Write-Host "   Database: $($databaseEndpoint.OutputValue)" -ForegroundColor Cyan }
    
} catch {
    Write-Host "❌ Erreur lors de la récupération des informations de la stack: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Fonction pour vérifier la santé des services ECS
function CheckECSServices {
    Write-Host "`n🔍 Vérification des services ECS..." -ForegroundColor Blue
    
    try {
        $services = aws ecs list-services --cluster $ecsClusterName.OutputValue --region $Region | ConvertFrom-Json
        
        if (-not $services.serviceArns) {
            Write-Host "   ⚠️  Aucun service trouvé dans le cluster" -ForegroundColor Yellow
            return
        }
        
        $serviceNames = $services.serviceArns | ForEach-Object { $_.Split('/')[-1] }
        Write-Host "   Services trouvés: $($serviceNames -join ', ')" -ForegroundColor Gray
        
        # Vérifier la santé de chaque service
        foreach ($serviceName in $serviceNames) {
            Write-Host "`n   📊 Service: $serviceName" -ForegroundColor Cyan
            
            $serviceDetails = aws ecs describe-services --cluster $ecsClusterName.OutputValue --services $serviceName --region $Region | ConvertFrom-Json
            
            if ($serviceDetails.services) {
                $service = $serviceDetails.services[0]
                
                Write-Host "     Status: $($service.status)" -ForegroundColor $(if ($service.status -eq "ACTIVE") { "Green" } else { "Red" })
                Write-Host "     Desired Count: $($service.desiredCount)" -ForegroundColor Gray
                Write-Host "     Running Count: $($service.runningCount)" -ForegroundColor Gray
                Write-Host "     Pending Count: $($service.pendingCount)" -ForegroundColor Gray
                
                if ($service.events) {
                    $latestEvent = $service.events[0]
                    Write-Host "     Dernier événement: $($latestEvent.message)" -ForegroundColor Gray
                }
                
                # Vérifier les tâches
                $tasks = aws ecs list-tasks --cluster $ecsClusterName.OutputValue --service-name $serviceName --region $Region | ConvertFrom-Json
                
                if ($tasks.taskArns) {
                    Write-Host "     Tâches actives: $($tasks.taskArns.Count)" -ForegroundColor Gray
                    
                    foreach ($taskArn in $tasks.taskArns[0..2]) { # Limiter à 3 tâches
                        $taskDetails = aws ecs describe-tasks --cluster $ecsClusterName.OutputValue --tasks $taskArn --region $Region | ConvertFrom-Json
                        
                        if ($taskDetails.tasks) {
                            $task = $taskDetails.tasks[0]
                            $taskId = $task.taskArn.Split('/')[-1]
                            Write-Host "       Tâche $taskId: $($task.lastStatus) - $($task.healthStatus)" -ForegroundColor Gray
                        }
                    }
                }
            }
        }
        
    } catch {
        Write-Host "   ❌ Erreur lors de la vérification des services ECS: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Fonction pour vérifier la santé des ALB
function CheckALBHealth {
    Write-Host "`n🔍 Vérification des Application Load Balancers..." -ForegroundColor Blue
    
    if ($backendAlbDns) {
        Write-Host "   📊 Backend ALB: $($backendAlbDns.OutputValue)" -ForegroundColor Cyan
        
        try {
            # Test de connectivité HTTP
            $response = Invoke-WebRequest -Uri "http://$($backendAlbDns.OutputValue)/api/health" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            Write-Host "     ✅ Health check: $($response.StatusCode) - $($response.StatusDescription)" -ForegroundColor Green
        } catch {
            Write-Host "     ❌ Health check échoué: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($frontendAlbDns) {
        Write-Host "   📊 Frontend ALB: $($frontendAlbDns.OutputValue)" -ForegroundColor Cyan
        
        try {
            # Test de connectivité HTTP
            $response = Invoke-WebRequest -Uri "http://$($frontendAlbDns.OutputValue)/" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            Write-Host "     ✅ Connectivité: $($response.StatusCode) - $($response.StatusDescription)" -ForegroundColor Green
        } catch {
            Write-Host "     ❌ Connectivité échouée: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Fonction pour vérifier la base de données
function CheckDatabase {
    Write-Host "`n🔍 Vérification de la base de données..." -ForegroundColor Blue
    
    if ($databaseEndpoint) {
        Write-Host "   📊 Endpoint: $($databaseEndpoint.OutputValue)" -ForegroundColor Cyan
        
        try {
            # Vérifier si l'endpoint est accessible (ping)
            $ping = Test-NetConnection -ComputerName $databaseEndpoint.OutputValue -Port 5432 -InformationLevel Quiet
            if ($ping) {
                Write-Host "     ✅ Port 5432 accessible" -ForegroundColor Green
            } else {
                Write-Host "     ❌ Port 5432 non accessible" -ForegroundColor Red
            }
        } catch {
            Write-Host "     ⚠️  Impossible de tester la connectivité: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  Endpoint de base de données non trouvé" -ForegroundColor Yellow
    }
}

# Fonction pour vérifier les logs CloudWatch
function CheckCloudWatchLogs {
    Write-Host "`n🔍 Vérification des logs CloudWatch..." -ForegroundColor Blue
    
    $logGroups = @(
        "/ecs/$Environment-flighthub-backend",
        "/ecs/$Environment-flighthub-frontend"
    )
    
    foreach ($logGroup in $logGroups) {
        Write-Host "   📊 Log Group: $logGroup" -ForegroundColor Cyan
        
        try {
            $logs = aws logs describe-log-streams --log-group-name $logGroup --order-by LastEventTime --descending --max-items 1 --region $Region | ConvertFrom-Json
            
            if ($logs.logStreams) {
                $latestStream = $logs.logStreams[0]
                Write-Host "     Dernier stream: $($latestStream.logStreamName)" -ForegroundColor Gray
                Write-Host "     Dernier événement: $($latestStream.lastEventTimestamp)" -ForegroundColor Gray
            } else {
                Write-Host "     ⚠️  Aucun stream de logs trouvé" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "     ❌ Erreur lors de la vérification des logs: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Exécuter toutes les vérifications
CheckECSServices
CheckALBHealth
CheckDatabase
CheckCloudWatchLogs

# Résumé et recommandations
Write-Host "`n📋 Résumé et recommandations:" -ForegroundColor Green

Write-Host "`n🔍 Commandes utiles pour le debugging:" -ForegroundColor Yellow
Write-Host "   Vérifier les services ECS:" -ForegroundColor Gray
Write-Host "     aws ecs describe-services --cluster $($ecsClusterName.OutputValue) --region $Region" -ForegroundColor White
Write-Host "   Vérifier les tâches ECS:" -ForegroundColor Gray
Write-Host "     aws ecs list-tasks --cluster $($ecsClusterName.OutputValue) --region $Region" -ForegroundColor White
Write-Host "   Vérifier les logs CloudWatch:" -ForegroundColor Gray
Write-Host "     aws logs tail /ecs/$Environment-flighthub-backend --region $Region" -ForegroundColor White
Write-Host "     aws logs tail /ecs/$Environment-flighthub-frontend --region $Region" -ForegroundColor White

Write-Host "`n🎯 URLs d'accès:" -ForegroundColor Yellow
if ($backendAlbDns) {
    Write-Host "   Backend API: http://$($backendAlbDns.OutputValue)" -ForegroundColor Cyan
}
if ($frontendAlbDns) {
    Write-Host "   Frontend: http://$($frontendAlbDns.OutputValue)" -ForegroundColor Cyan
}

Write-Host "`n✅ Vérification de la santé terminée!" -ForegroundColor Green


