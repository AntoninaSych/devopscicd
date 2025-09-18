# Фінальний проєкт

## Технічні вимоги

- **Інфраструктура**: AWS з використанням Terraform
- **Компоненти**: VPC, EKS, RDS, ECR, Jenkins, Argo CD, Prometheus, Grafana
---


## Етапи виконання

1. **Підготовка середовища**:

- Ініціалізувати Terraform.
- Перевірити всі необхідні змінні та параметри.


2. **Розгортання інфраструктури**:

- Виконати команду розгортання:
```
terraform apply
```

- Перевірити стан ресурсів через:
```
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

3. **Перевірка доступності**:

- Jenkins:
```
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

- Argo CD:
```
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

4. **Моніторинг та перевірка метрик**:

- Grafana:
```
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

- Перевірити стан метрик в Grafana Dashboard.


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
├──django
│ 	├── goit\
│ 	├── Dockerfile
│ 	├── Jenkinsfile
│ 	└── docker-compose.yaml
│ 
└── README.md                # Документація проєкту
```

## Необхідні умови
- `AWS CLI` встановлено та налаштовано
- `kubectl` встановлено
- `Helm` встановлено
- `Docker` встановлено
- `Terraform` встановлено


## Налаштування змінних
У корні проєкту створіть файл `terraform.tfvars` з наступними змінними:

```
github_pat  = <github token>
github_user  = <github username>
github_repo_url = "https://github.com/<repo>.git"
github_branch = "main"

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

Відкрийте Jenkins LoadBalancer URL (username: admin; password: admin123)
- запустіть `seed-job` задачу (це створить нову задачу `django-docker`)
- запустіть `django-docker` задачу:
  - Збере та завантажить образ Docker до ECR
  - Об'єднає MR у вашому репозиторії з оновленням версії програми (відповідно до номера збірки завдання Jenkins `django-docker`)

![jenkins](./assets/jenkins.png)

Відкрити Argo CD LoadBalancer URL,
 Використовуйте логін admin, а щоб отримати пароль виконайте наступну команду `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d`
- перевірити статус `example-app` застосунку (має бути `Healthy` та `Synced`)

![argocd](./assets/argocd.png)

## Моніторинг
- перенаправити порт Grafana за допомогою наступної команди `kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80`
- відкрити http://localhost:3000
- ввести імʼя користувача `admin` та пароль, використавши наступну команду `kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode`
- перевірте панелі інструментів, щоб побачити використання процесора та пам'яті (POD, вузли тощо)

![grafana](./assets/grafana.png)

## Видалення ресурсів
```bash
terraform destroy
```
