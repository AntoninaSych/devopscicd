# Інструкція з розгортання (AWS EKS + ECR + Terraform + Helm)

Цей README описує мінімальний шлях від інфраструктури до деплою застосунку в Kubernetes на AWS.

## Вимоги
- **AWS Account** та сконфігурований `awscli` (`aws configure`)
- **Terraform** v1.x
- **kubectl**
- **Helm** v3
- **Docker** (для побудови образів)
- Права на створення ресурсів AWS (ECR, EKS, VPC, S3/DynamoDB для remote state)

### Змінні оточення (зручно, але не обовʼязково)
```bash
export AWS_REGION=eu-west-2
export EKS_CLUSTER_NAME=lesson7-eks
export ACCOUNT_ID=<YOUR_AWS_ACCOUNT_ID>


terraform init -upgrade
terraform apply
```

```terraform init -upgrade``` — ініціалізація Terraform і оновлення провайдерів.

```terraform apply ```— створення/оновлення інфраструктури (VPC, ECR, EKS, S3/DynamoDB).

```aws eks update-kubeconfig --region eu-west-2 --name lesson7-eks``` — підключення kubectl до кластера EKS.

```kubectl get nodes``` — перевірка доступності вузлів кластера.

```aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com``` — вхід у реєстр ECR.

```docker build -t lesson7-ecr:latest .``` — збірка Docker-образу застосунку.

```docker tag lesson7-ecr:latest <ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com/lesson7-ecr:latest``` — тегування образу для ECR.

```docker push <ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com/lesson7-ecr:latest``` — публікація образу в ECR.

```kubectl apply -f k8s/cluster-issuer.yaml ```— створення ClusterIssuer (TLS).

```helm upgrade --install django-app ./charts/django-app -f ./charts/django-app/values.yaml ```— деплой застосунку.

```kubectl get svc django-app -w``` — очікування зовнішньої адреси сервісу.

```kubectl logs deploy/django-app``` — перегляд логів деплойменту.

```helm uninstall django-app``` — видалення Helm-релізу (за потреби).

```terraform destroy``` — видалення інфраструктури.

Кроки розгортання
1) Інфраструктура (Terraform)
   terraform init -upgrade     # ініціалізація та оновлення провайдерів
   terraform apply             # створення/оновлення VPC, ECR, EKS, S3/DynamoDB backend

2) Доступ до кластера EKS
   aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
   kubectl get nodes

3) Логін у ECR, збірка та публікація Docker-образу Django
   aws ecr get-login-password --region ${AWS_REGION} \
   | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t lesson7-ecr:latest .
docker tag lesson7-ecr:latest ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/lesson7-ecr:latest
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/lesson7-ecr:latest

4) (Опційно) TLS через cert-manager
   kubectl apply -f k8s/cluster-issuer.yaml

5) Деплой через Helm
   helm upgrade --install django-app ./charts/django-app -f ./charts/django-app/values.yaml
   kubectl get svc django-app -w
   kubectl logs deploy/django-app

6) Видалення (за потреби)
   helm uninstall django-app
   terraform destroy

Що реалізовано у Helm-чарті

Deployment — образ із ECR + підключення ConfigMap через envFrom, probes.

Service (LoadBalancer) — зовнішній доступ до застосунку.

ConfigMap — перенесені змінні середовища з теми 4.

HPA — масштабує поди від 2 до 6 при >70% CPU.

Ingress + TLS (опційно) — вмикається через values.yaml.

Перевірка та діагностика
kubectl get deploy,po,svc,hpa
kubectl describe hpa django-app
kubectl top pods                      
kubectl port-forward svc/django-app 8080:80
