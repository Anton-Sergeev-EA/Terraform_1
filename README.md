# Продвинутые методы работы с Terraform

Выполнил Сергеев Антон.

Terraform `~> 1.12.0`. Два вызова закреплённого [удалённого модуля из демонстрации](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1/vms) создают по одной прерываемой ВМ Ubuntu с метками `project=marketing` и `project=analytics`. Модуль [vpc](vpc/README.md) создаёт одну сеть и одну подсеть, затем отдаёт объект подсети в корневой модуль. Группа безопасности разрешает SSH с адресов из `ssh_cidrs`.

Публичный SSH-ключ читается из файла, кодируется как JSON-массив и передаётся через `vars` в `data.template_file.cloudinit`. Массив в JSON синтаксически допустим в YAML. Cloud-init передаёт его в `ssh_authorized_keys` и устанавливает nginx через `packages`. [Пример настройки cloud-init](https://oneuptime.com/blog/post/2026-03-02-how-to-use-cloud-init-with-terraform-for-ubuntu-provisioning/view).

## Запуск

Проверено на Linux amd64. Понадобятся Terraform 1.12.x, сервисный аккаунт с правами Compute и VPC и пара SSH-ключей. Укажите путь к авторизованному ключу сервисного аккаунта, путь к публичному ключу и входной CIDR для SSH. Настройки и state хранятся локально.

```bash
cp terraform.tfvars.example personal.auto.tfvars
# Заполнить personal.auto.tfvars и при необходимости переопределить пути к ключам.
export TF_CLI_CONFIG_FILE="$PWD/.terraformrc"
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=deploy.tfplan
terraform apply deploy.tfplan
terraform-docs markdown table vpc > vpc/README.md
```

## Работа со state

До удаления из state сохраните четыре ID из `terraform show -json`: сеть, подсеть и две ВМ. Группа безопасности остаётся в state. Два источника данных образов Terraform читает заново при построении плана. `state rm` снимает привязку Terraform без удаления объектов из облака.

```bash
terraform state list
terraform state rm module.vpc_dev module.marketing_vm module.analytics_vm
terraform state list
# Добавить imports.tf с блоком import на каждый из четырёх сохранённых ID.
terraform plan -out=import.tfplan
terraform apply import.tfplan
# Убрать временный imports.tf, затем проверить обычный план.
terraform state list
terraform plan -detailed-exitcode
```

Точные адреса и блоки импорта приведены в [журнале обратного импорта](evidence/state-imported.txt). План вернул четыре импорта, ноль добавлений и удалений. Два обновления восстановили флаг провайдера `allow_stopping_for_update` у импортированных ВМ. Следующий обычный план показал `No changes` с кодом возврата 0.

## Доказательства

- [ВМ и метки в Yandex Cloud](evidence/vm-labels.png)
- [Подключение по SSH и nginx -t](evidence/nginx.png), [вывод команды](evidence/nginx.txt)
- [Вывод terraform console для marketing_vm](evidence/module-marketing.png) и [vpc_dev](evidence/module-vpc.png)
- [State до удаления](evidence/state-before.png), [после удаления](evidence/state-removed.png) и [после обратного импорта](evidence/state-imported.png)
- [Итоговый план](evidence/plan-after-import.txt)
- [Подтверждение очистки](evidence/cleanup.txt)

Скриншоты CLI сделаны в локальном просмотрщике фактического вывода команд. Значения IP и ID относятся к учебному запуску.
