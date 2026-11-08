# infra-monitoring-project

Мониторинг доступности echo-API: проверка API по коду ответа, анализ access-логов, контейнеризированный стек (API + nginx-прокси) и CI-пайплайн на GitHub Actions.

## Требования

- bash, curl
- Docker и Docker Compose

## Запуск

### Проверка доступности API

```bash
./check_api.sh https://httpbin.org/status/200
```

```
API доступен
```

Код возврата: `0`, если API ответил `200`, иначе `1`.

### Анализ логов

```bash
./analyze_logs.sh
```

Скрипт создаёт `access.log` на 300 записей и выводит:

```
Общее количество запросов: 300
Топ-3 IP-адреса:
  192.168.1.10 - 120
  10.0.0.5 - 73
  192.168.1.15 - 40
Запросов с кодами 4xx: 89
Запросов с кодами 5xx: 79
```

### Стек мониторинга

```bash
docker-compose up -d
docker-compose ps
curl http://localhost:80
```

```
Monitoring Service Active
```

Остановка:

```bash
docker-compose down
```

## Деплой на удалённый сервер

В примерах сервер — `deploy@203.0.113.10`, каталог проекта на сервере — `~/infra-monitoring-project`.

### 1. Генерация SSH-ключа

```bash
ssh-keygen -t ed25519 -C "deploy@infra-monitoring"
```

Ключи сохраняются в `~/.ssh/id_ed25519` (закрытый) и `~/.ssh/id_ed25519.pub` (открытый). Закрытый ключ остаётся только на локальной машине, при генерации для него задаётся пароль.

### 2. Копирование открытого ключа на сервер

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub deploy@203.0.113.10
```

Команда добавляет ключ в `~/.ssh/authorized_keys` на сервере. Последний раз вводится пароль пользователя, дальше вход идёт по ключу:

```bash
ssh deploy@203.0.113.10
```

### 3. Передача архива проекта через scp

В архив попадают только файлы, нужные для запуска: без `.git`, логов и `report`. `COPYFILE_DISABLE=1` нужен на macOS, чтобы `tar` не добавлял служебные файлы `._*`.

```bash
COPYFILE_DISABLE=1 tar -czf ../infra-monitoring-project.tar.gz --exclude=.git --exclude=access.log --exclude=report .
scp ../infra-monitoring-project.tar.gz deploy@203.0.113.10:/tmp/
ssh deploy@203.0.113.10 "mkdir -p ~/infra-monitoring-project && tar -xzf /tmp/infra-monitoring-project.tar.gz -C ~/infra-monitoring-project && rm /tmp/infra-monitoring-project.tar.gz"
```

### 4. Запуск на сервере

```bash
ssh deploy@203.0.113.10 "cd ~/infra-monitoring-project && docker-compose up -d && ./check_api.sh http://localhost"
```

```
API доступен
```
