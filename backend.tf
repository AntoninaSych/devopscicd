# Розкоментуйте, щоб підключити бекенд до Terraform

# terraform {
#   backend "s3" {
#     bucket         = "orm81zp-terraform-state-bucket-lesson-10"  # Назва S3-бакета
#     key            = "lesson-10/terraform.tfstate"               # Шлях до файлу стейту
#     region         = "us-east-1"                                  # Регіон AWS
#     dynamodb_table = "terraform-locks"                            # Назва таблиці DynamoDB
#     encrypt        = true                                         # Шифрування файлу стейту
#   }
# }
