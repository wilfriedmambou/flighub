# 🚀 Infrastructure AWS FlightHub

Ce répertoire contient tous les scripts et templates CloudFormation nécessaires pour déployer FlightHub sur AWS avec une architecture moderne et scalable.

## 🏗️ Architecture

L'infrastructure FlightHub comprend :

- **VPC** avec subnets publics et privés
- **RDS PostgreSQL** pour la base de données
- **ECR** pour les registres d'images Docker
- **ECS Fargate** pour l'exécution des conteneurs
- **Application Load Balancers** pour la distribution du trafic
- **Security Groups** pour la sécurité réseau
- **CloudWatch** pour la surveillance et les logs
- **IAM** pour les permissions

## 📁 Structure des fichiers

```
aws/
├── flighthub-stack.yml              # Template CloudFormation principal
├── deploy-stack.ps1                 # Script de déploiement de l'infrastructure
├── build-and-push-images.ps1        # Script de build et push des images Docker
├── update-ecs-services.ps1          # Script de mise à jour des services ECS
├── check-services-health.ps1        # Script de vérification de la santé
├── deploy-complete.ps1              # Script principal de déploiement complet
└── README.md                        # Ce fichier
```

## 🚀 Déploiement rapide

### Prérequis

1. **AWS CLI** installé et configuré
2. **Docker** installé et en cours d'exécution
3. **PowerShell** (Windows) ou **Bash** (Linux/Mac)
4. **Compte AWS** avec permissions suffisantes

### Configuration AWS

```bash
# Configurer AWS CLI
aws configure

# Vérifier la configuration
aws sts get-caller-identity
```

### Déploiement complet en une commande

```powershell
# Déploiement complet avec health check
.\deploy-complete.ps1 -Environment production -DatabasePassword "VotreMotDePasseSecurise123!" -Region us-east-1 -HealthCheck

# Déploiement en mode développement
.\deploy-complete.ps1 -Environment development -DatabasePassword "DevPassword123!" -Region us-east-1
```

## 🔧 Déploiement étape par étape

### 1. Déploiement de l'infrastructure

```powershell
# Créer/mettre à jour la stack CloudFormation
.\deploy-stack.ps1 -Environment production -DatabasePassword "VotreMotDePasse" -Region us-east-1
```

**Paramètres disponibles :**
- `Environment` : development, staging, production
- `DatabasePassword` : Mot de passe pour la base de données RDS
- `StackName` : Nom de la stack CloudFormation (défaut: flighthub-stack)
- `Region` : Région AWS (défaut: us-east-1)

### 2. Build et push des images Docker

```powershell
# Construire et pousser les images vers ECR
.\build-and-push-images.ps1 -Environment production -Region us-east-1 -ImageTag v1.0.0
```

**Paramètres disponibles :**
- `Environment` : Environnement de déploiement
- `Region` : Région AWS
- `StackName` : Nom de la stack
- `ImageTag` : Tag des images Docker (défaut: latest)

### 3. Mise à jour des services ECS

```powershell
# Mettre à jour les services avec les nouvelles images
.\update-ecs-services.ps1 -Environment production -Region us-east-1 -ImageTag v1.0.0
```

### 4. Vérification de la santé

```powershell
# Vérifier l'état des services
.\check-services-health.ps1 -Environment production -Region us-east-1
```

## 🎯 Utilisation des scripts

### Script principal de déploiement

Le script `deploy-complete.ps1` orchestre tout le processus :

```powershell
# Déploiement complet
.\deploy-complete.ps1 -Environment production -DatabasePassword "MotDePasse123!" -HealthCheck

# Ignorer certaines étapes
.\deploy-complete.ps1 -Environment production -DatabasePassword "MotDePasse123!" -SkipInfrastructure -SkipBuild

# Déploiement avec tag personnalisé
.\deploy-complete.ps1 -Environment production -DatabasePassword "MotDePasse123!" -ImageTag v2.0.0
```

**Options disponibles :**
- `-SkipInfrastructure` : Ignorer le déploiement de l'infrastructure
- `-SkipBuild` : Ignorer le build des images Docker
- `-SkipDeploy` : Ignorer le déploiement des services ECS
- `-HealthCheck` : Activer la vérification de la santé après déploiement

### Scripts individuels

Chaque script peut être exécuté indépendamment :

```powershell
# Déploiement de l'infrastructure uniquement
.\deploy-stack.ps1 -Environment production -DatabasePassword "MotDePasse123!"

# Build des images uniquement
.\build-and-push-images.ps1 -Environment production

# Mise à jour des services uniquement
.\update-ecs-services.ps1 -Environment production

# Vérification de la santé uniquement
.\check-services-health.ps1 -Environment production
```

## 🔍 Monitoring et debugging

### Vérification de la santé des services

```powershell
# Vérification complète
.\check-services-health.ps1 -Environment production -Region us-east-1
```

### Logs CloudWatch

```bash
# Logs du backend
aws logs tail /ecs/production-flighthub-backend --region us-east-1

# Logs du frontend
aws logs tail /ecs/production-flighthub-frontend --region us-east-1
```

### État des services ECS

```bash
# Lister les services
aws ecs list-services --cluster production-flighthub-cluster --region us-east-1

# Détails d'un service
aws ecs describe-services --cluster production-flighthub-cluster --services production-flighthub-backend-service --region us-east-1
```

### État de la stack CloudFormation

```bash
# Détails de la stack
aws cloudformation describe-stacks --stack-name flighthub-stack --region us-east-1

# Événements de la stack
aws cloudformation describe-stack-events --stack-name flighthub-stack --region us-east-1
```

## 🗄️ Base de données

### Connexion à RDS

```bash
# Connexion via psql (si installé)
psql -h <endpoint-rds> -U flighthub_admin -d flighthub

# Connexion via AWS CLI
aws rds describe-db-instances --db-instance-identifier production-flighthub-db --region us-east-1
```

### Migration et seeding

Après le déploiement, exécutez les migrations Laravel :

```bash
# Via ECS Exec (si configuré)
aws ecs execute-command --cluster production-flighthub-cluster --task <task-id> --command "/bin/bash" --interactive

# Ou via une tâche ECS ponctuelle
aws ecs run-task --cluster production-flighthub-cluster --task-definition production-flighthub-backend --overrides '{"containerOverrides":[{"name":"backend","command":["php","artisan","migrate","--force"]}]}'
```

## 🔐 Sécurité

### Security Groups

- **ALB** : Ports 80 et 443 ouverts au monde
- **Backend** : Ports 80 et 8000 accessibles uniquement depuis l'ALB
- **Frontend** : Ports 80 et 3000 accessibles uniquement depuis l'ALB
- **Database** : Port 5432 accessible uniquement depuis le backend

### IAM Roles

- **ECSTaskExecutionRole** : Permissions pour ECR et CloudWatch
- **ECSTaskRole** : Permissions pour S3 et autres services AWS

### Chiffrement

- **RDS** : Chiffrement au repos activé
- **Transit** : HTTPS pour les communications externes

## 📊 Coûts estimés

**Développement (us-east-1) :**
- RDS db.t3.micro : ~$15/mois
- ECS Fargate (2x256 CPU, 512MB) : ~$20/mois
- ALB : ~$20/mois
- NAT Gateway : ~$45/mois
- **Total estimé : ~$100/mois**

**Production (us-east-1) :**
- RDS db.t3.small : ~$30/mois
- ECS Fargate (2x512 CPU, 1GB) : ~$40/mois
- ALB : ~$20/mois
- NAT Gateway : ~$45/mois
- **Total estimé : ~$135/mois**

## 🚨 Dépannage

### Problèmes courants

1. **Stack CloudFormation échoue**
   - Vérifiez les permissions IAM
   - Vérifiez les quotas AWS
   - Consultez les événements de la stack

2. **Images Docker ne se poussent pas**
   - Vérifiez la connexion ECR
   - Vérifiez les permissions ECR
   - Vérifiez que Docker est en cours d'exécution

3. **Services ECS ne démarrent pas**
   - Vérifiez les logs CloudWatch
   - Vérifiez la connectivité réseau
   - Vérifiez les variables d'environnement

4. **Health checks échouent**
   - Vérifiez les security groups
   - Vérifiez les routes
   - Vérifiez la configuration des target groups

### Commandes de diagnostic

```bash
# Vérifier la connectivité réseau
aws ec2 describe-network-interfaces --filters "Name=description,Values=*flighthub*" --region us-east-1

# Vérifier les security groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=*flighthub*" --region us-east-1

# Vérifier les logs d'erreur
aws logs filter-log-events --log-group-name /ecs/production-flighthub-backend --filter-pattern "ERROR" --region us-east-1
```

## 🔄 Mise à jour et maintenance

### Mise à jour des images

```powershell
# Mise à jour complète
.\deploy-complete.ps1 -Environment production -DatabasePassword "MotDePasse123!" -ImageTag v1.1.0 -HealthCheck

# Mise à jour des services uniquement
.\update-ecs-services.ps1 -Environment production -ImageTag v1.1.0
```

### Mise à jour de l'infrastructure

```powershell
# Mise à jour de la stack
.\deploy-stack.ps1 -Environment production -DatabasePassword "MotDePasse123!"
```

### Sauvegarde et restauration

```bash
# Créer un snapshot RDS
aws rds create-db-snapshot --db-instance-identifier production-flighthub-db --db-snapshot-identifier backup-$(date +%Y%m%d) --region us-east-1

# Restaurer depuis un snapshot
aws rds restore-db-instance-from-db-snapshot --db-instance-identifier production-flighthub-db-restored --db-snapshot-identifier backup-20241201 --region us-east-1
```

## 📚 Ressources et documentation

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

## 🤝 Support et contribution

Pour toute question ou problème :

1. Vérifiez les logs CloudWatch
2. Consultez la documentation AWS
3. Vérifiez les permissions IAM
4. Testez la connectivité réseau

---

**Note :** Cette infrastructure est conçue pour la production mais peut être adaptée pour le développement et le staging. Ajustez les paramètres selon vos besoins.


