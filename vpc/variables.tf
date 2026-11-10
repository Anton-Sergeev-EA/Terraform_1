variable "name" {
  description = "Имя сети."
  type        = string
}
variable "zone" {
  description = "Зона доступности подсети."
  type        = string
}
variable "v4_cidr_blocks" {
  description = "Блоки IPv4 подсети в записи CIDR."
  type        = list(string)
}
