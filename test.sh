#!/bin/bash

PROCESS_NAME="test"
LOGFILE="/var/log/monitoring.log"
SERVER_URL="https://test.com/monitoring/test/api"

check_pid() {
    pgrep -x "$PROCESS_NAME"
}

echo "$(date): Запущен скрипт мониторинга" >> "$LOGFILE"

initial_pid=$(check_pid)
while true; do
    new_pid=$(check_pid)

    if [ -n "$new_pid" ]; then
	# Проверяю на перезапуск через id процесса
	if [ "$new_pid" != "$initial_pid" ]; then
     	    echo "$(date): Процесс $PROCESS_NAME был перезапущен" >> "$LOGFILE"
            initial_pid=$new_pid
	fi

	# Код состояния ответа
	status_code=$(curl -s -o /dev/null "$SERVER_URL" -w "%{http_code}" )

	# Если совсем недостучались до сервера и не получили даже код ошибки 
	if [ "$status_code" -eq 0 ]; then
	    echo "$(date): Сервер не доступен" >> "$LOGFILE"  
	fi
    fi

    sleep 60;
done

