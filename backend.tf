# Розкоментуйте, щоб підключити бекенд до Terraform

# terraform {
#   backend "s3" {
#     bucket         = "orm81zp-terraform-state-bucket-lesson-8-9"  # Назва S3-бакета
#     key            = "lesson-8-9/terraform.tfstate"               # Шлях до файлу стейту
#     region         = "us-east-1"                                  # Регіон AWS
#     dynamodb_table = "terraform-locks"                            # Назва таблиці DynamoDB
#     encrypt        = true                                         # Шифрування файлу стейту
#   }
# }
