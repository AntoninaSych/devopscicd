variable "repository_name" {
  description = "Назва репозиторію ECR"
  type        = string
}

variable "scan_on_push" {
  description = "Увімкнути сканування зображень під час пушу"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  type        = string
  description = "IMMUTABLE заблокує зміну існуючих тегів; MUTABLE дозволяє перезапис."
  default     = "MUTABLE"
}

variable "force_delete" {
  type        = bool
  description = "Якщо true, видалення репо автоматично видаляє всі образи всередині."
  default     = true
}

variable "repository_policy" {
  type        = string
  description = "JSON-політика репозиторію."
  default     = null
}
