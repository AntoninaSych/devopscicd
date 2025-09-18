# Домашнє завдання: Створення гнучкого Terraform-модуля для баз даних

## Опис завдання
Реалізувати універсальний модуль `rds`, який:

1. Підіймає Aurora Cluster або звичайну RDS instance на основі значення `use_aurora`;
2. Автоматично створює:
   - **DB Subnet Group**
   - **Security Group**
   - **Parameter Group** для обраного типу БД
3. Працює з мінімальними змінами змінних і підтримує багаторазове використання.

---

## Структура проєкту

```
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію ECR
│   │
│   ├── eks/                 # Модуль для створення EKS-кластеру
│   │   ├── eks.tf           # Створення EKS та Node Groups
│   │   ├── variables.tf     # Змінні модуля
│   │   └── outputs.tf       # Параметри кластера
│   │
│   ├── rds/                 # Модуль для RDS
│   │   ├── rds.tf           # Створення RDS бази даних  
│   │   ├── aurora.tf        # Створення aurora кластера бази даних  
│   │   ├── shared.tf        # Спільні ресурси  
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   └── outputs.tf  
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │
│   └── argo_cd/             # Модуль для Helm-установки Argo CD
│      ├── jenkins.tf       # Helm release для Jenkins
│      ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│      ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│      ├── values.yaml      # Кастомна конфігурація Argo CD
│      ├── outputs.tf       # Виводи (hostname, initial admin password)
│      └──charts/                  # Helm-чарт для створення app'ів
│         ├── Chart.yaml
│         ├── values.yaml          # Список applications, repositories
│         └── templates/
│             ├── application.yaml
│             └── repository.yaml
│
├── charts/                        # Helm-чарти
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml    # Deployment для Django-застосунку
│       │   ├── service.yaml       # LoadBalancer Service
│       │   ├── configmap.yaml     # Змінні середовища
│       │   └── hpa.yaml           # Horizontal Pod Autoscaler
│       ├── Chart.yaml             # Метадані чарта
│       └── values.yaml            # Конфігураційні значення (ConfigMap зі змінними середовища)
│ 
└── README.md                # Документація проєкту
```

## Функціонал модуля:

- `use_aurora` = `true` → створюється Aurora Cluster + writer;
- `use_aurora` = `false` → створюється одна `aws_db_instance`;
- В обох випадках:
  - створюється `aws_db_subnet_group`;
  - створюється `aws_security_group`;
  - створюється `parameter group` з базовими параметрами (`max_connections`, `log_statement`, `work_mem`);
  - Параметри `engine`, `engine_version`, `instance_class`, `multi_az` задаються через змінні.

## Налаштування змінних
У корні проєкту створіть файл `terraform.tfvars` з наступними змінними:

```
github_token  = <github_token>
github_username  = <github_username>
github_repo_url = "https://github.com/<repo>.git"

rds_password = <rds_password>
rds_username = <rds_username>
rds_database_name = <rds_database_name>
rds_publicly_accessible = true

# true → створюється Aurora Cluster + writer
# false → створюється одна aws_db_instance
rds_use_aurora = true

rds_multi_az = false
rds_backup_retention_period = "0"
```

Або можете використати `terraform.tfvars.example` як приклад.

## Налаштування середовища
`region` за замовченням `us-east-1`

```
terraform init
terraform plan
terraform apply
```

## Налаштування kubectl

```bash
# Підключення до EKS-кластеру
aws eks update-kubeconfig --region us-east-1 --name <your_cluster_name>

# Перевірка доступу
kubectl get nodes

# або перевірка сервісів в кластері:
kubectl get svc -A
```
![bash](./assets/bash.png)
![jenkins](./assets/jenkins.png)

## Видалення ресурсів
```bash
terraform destroy
```

## Налаштування віддаленого бекенду

Після початкового розгортання для активації віддаленого бекенду:

1. Розкоментуйте блок конфігурації бекенду в `backend.tf`.

2. Виконайте команду `terraform init` з параметром для повторного підключення бекенду:

```bash
terraform init -reconfigure
```

## Відновлення
1. Закоментуйте конфігурацію бекенду в `backend.tf`.
2. Виконайте `terraform init`.
3. Застосуйте конфігурацію `terraform apply`.
4. Розкоментуйте бекенд та виконайте `terraform init -reconfigure`.

## Приклад Aurora Cluster
![rds](./assets/rds.png)
![rds-cluster](./assets/rds-cluster.png)
