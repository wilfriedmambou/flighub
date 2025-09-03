# Script de déploiement de la stack FlightHub sur AWS
# Utilisation: .\deploy-stack.ps1 -Environment production -DatabasePassword "VotreMotDePasse"

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$true)]
    [string]$DatabasePassword,
    
    [Parameter(Mandatory=$false)]
    [string]$StackName = "flighthub-stack",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1"
)

Write-Host "🚀 Déploiement de la stack FlightHub sur AWS..." -ForegroundColor Green
Write-Host "Environnement: $Environment" -ForegroundColor Yellow
Write-Host "Région: $Region" -ForegroundColor Yellow
Write-Host "Nom de la stack: $StackName" -ForegroundColor Yellow

# Vérifier que AWS CLI est installé
try {
    $awsVersion = aws --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "AWS CLI non trouvé"
    }
    Write-Host "✅ AWS CLI détecté: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "Veuillez installer AWS CLI depuis: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

# Vérifier la configuration AWS
Write-Host "🔐 Vérification de la configuration AWS..." -ForegroundColor Blue
try {
    $awsIdentity = aws sts get-caller-identity --region $Region 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        throw "Impossible de récupérer l'identité AWS"
    }
    Write-Host "✅ Connecté en tant que: $($awsIdentity.Arn)" -ForegroundColor Green
    Write-Host "   Account ID: $($awsIdentity.Account)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de configuration AWS. Vérifiez vos credentials avec 'aws configure'" -ForegroundColor Red
    exit 1
}

# Vérifier que le fichier de template existe
$templateFile = "flighthub-stack.yml"
if (-not (Test-Path $templateFile)) {
    Write-Host "❌ Fichier de template non trouvé: $templateFile" -ForegroundColor Red
    exit 1
}

# Paramètres de la stack
$stackParams = @(
    "ParameterKey=Environment,ParameterValue=$Environment",
    "ParameterKey=DatabasePassword,ParameterValue=$DatabasePassword",
    "ParameterKey=DatabaseUsername,ParameterValue=flighthub_admin",
    "ParameterKey=DatabaseName,ParameterValue=flighthub",
    "ParameterKey=DatabaseInstanceClass,ParameterValue=db.t3.micro",
    "ParameterKey=ContainerCpu,ParameterValue=256",
    "ParameterKey=ContainerMemory,ParameterValue=512"
)

# Vérifier si la stack existe déjà
Write-Host "🔍 Vérification de l'existence de la stack..." -ForegroundColor Blue
$stackExists = aws cloudformation describe-stacks --stack-name $StackName --region $Region 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "⚠️  La stack '$StackName' existe déjà. Mise à jour en cours..." -ForegroundColor Yellow
    
    # Mise à jour de la stack existante
    Write-Host "📝 Mise à jour de la stack..." -ForegroundColor Blue
    $updateCmd = "aws cloudformation update-stack --stack-name $StackName --template-body file://$templateFile --parameters $($stackParams -join ' ') --region $Region --capabilities CAPABILITY_NAMED_IAM"
    
    Write-Host "Commande: $updateCmd" -ForegroundColor Gray
    Invoke-Expression $updateCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Mise à jour de la stack lancée avec succès!" -ForegroundColor Green
        Write-Host "⏳ Attente de la finalisation de la mise à jour..." -ForegroundColor Yellow
        
        # Attendre la finalisation de la mise à jour
        aws cloudformation wait stack-update-complete --stack-name $StackName --region $Region
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Stack mise à jour avec succès!" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreur lors de la mise à jour de la stack" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Erreur lors du lancement de la mise à jour" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🆕 Création d'une nouvelle stack..." -ForegroundColor Blue
    
    # Création d'une nouvelle stack
    $createCmd = "aws cloudformation create-stack --stack-name $StackName --template-body file://$templateFile --parameters $($stackParams -join ' ') --region $Region --capabilities CAPABILITY_NAMED_IAM"
    
    Write-Host "Commande: $createCmd" -ForegroundColor Gray
    Invoke-Expression $createCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Création de la stack lancée avec succès!" -ForegroundColor Green
        Write-Host "⏳ Attente de la finalisation de la création..." -ForegroundColor Yellow
        
        # Attendre la finalisation de la création
        aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Stack créée avec succès!" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreur lors de la création de la stack" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Erreur lors du lancement de la création" -ForegroundColor Red
        exit 1
    }
}

# Récupérer les outputs de la stack
Write-Host "📊 Récupération des informations de la stack..." -ForegroundColor Blue
$stackOutputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].Outputs' | ConvertFrom-Json

if ($stackOutputs) {
    Write-Host "✅ Outputs de la stack:" -ForegroundColor Green
    foreach ($output in $stackOutputs) {
        Write-Host "   $($output.OutputKey): $($output.OutputValue)" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠️  Aucun output trouvé pour la stack" -ForegroundColor Yellow
}

# Instructions post-déploiement
Write-Host "`n🎯 Prochaines étapes:" -ForegroundColor Green
Write-Host "1. Construire et pousser les images Docker vers ECR" -ForegroundColor White
Write-Host "2. Mettre à jour les services ECS avec les nouvelles images" -ForegroundColor White
Write-Host "3. Vérifier la santé des services" -ForegroundColor White
Write-Host "4. Tester l'application via les URLs des ALB" -ForegroundColor White

Write-Host "`n🔗 URLs d'accès:" -ForegroundColor Green
$frontendAlb = $stackOutputs | Where-Object { $_.OutputKey -eq "FrontendALBDNSName" }
$backendAlb = $stackOutputs | Where-Object { $_.OutputKey -eq "BackendALBDNSName" }

if ($frontendAlb) {
    Write-Host "   Frontend: http://$($frontendAlb.OutputValue)" -ForegroundColor Cyan
}
if ($backendAlb) {
    Write-Host "   Backend API: http://$($backendAlb.OutputValue)" -ForegroundColor Cyan
}

Write-Host "`n✅ Déploiement terminé avec succès!" -ForegroundColor Green


