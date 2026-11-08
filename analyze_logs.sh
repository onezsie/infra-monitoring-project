#!/bin/bash

LOG_FILE="access.log"
LINES=300

IPS=(192.168.1.10 192.168.1.10 192.168.1.10 10.0.0.5 10.0.0.5 172.16.0.21 192.168.1.15 10.0.0.8)
REQUESTS=("GET /api/users" "POST /api/login" "GET /api/orders" "PUT /api/users/42" "DELETE /api/orders/7")
CODES=(200 200 200 200 201 301 400 401 403 404 500 502 503)

> "$LOG_FILE"
for ((i = 0; i < LINES; i++)); do
  IP=${IPS[RANDOM % ${#IPS[@]}]}
  REQUEST=${REQUESTS[RANDOM % ${#REQUESTS[@]}]}
  CODE=${CODES[RANDOM % ${#CODES[@]}]}
  SEC=$((15 * 60 + i))
  printf '%s - - [15/Aug/2026:10:%02d:%02d] "%s HTTP/1.1" %s\n' \
    "$IP" $((SEC / 60)) $((SEC % 60)) "$REQUEST" "$CODE" >> "$LOG_FILE"
done

IP_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}'

echo "Общее количество запросов: $(grep -cE "$IP_REGEX" "$LOG_FILE")"

echo "Топ-3 IP-адреса:"
grep -oE "$IP_REGEX" "$LOG_FILE" | sort | uniq -c | sort -rn | head -3 | awk '{print "  " $2 " - " $1}'

echo "Запросов с кодами 4xx: $(awk '$NF ~ /^4[0-9][0-9]$/' "$LOG_FILE" | wc -l | tr -d ' ')"
echo "Запросов с кодами 5xx: $(awk '$NF ~ /^5[0-9][0-9]$/' "$LOG_FILE" | wc -l | tr -d ' ')"
