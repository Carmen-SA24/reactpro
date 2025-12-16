#!/bin/bash
# port-scanner.sh - Monitor de seguridad de puertos
# Monitorea puertos 22 (SSH), 80 (Nginx), 3000 (React)

LOG_FILE="/var/log/port-scanner.log"
SCAN_INTERVAL=60  # Segundos entre escaneos

# Crear archivo de log si no existe
touch "$LOG_FILE"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_port() {
    local port=$1
    local service=$2
    
    if netstat -tuln | grep -q ":${port} "; then
        log_message "✅ Puerto ${port} (${service}): ACTIVO"
        return 0
    else
        log_message "❌ Puerto ${port} (${service}): INACTIVO - ALERTA"
        return 1
    fi
}

log_message "🔒 Iniciando scanner de seguridad..."
log_message "📡 Monitoreando puertos: 22 (SSH), 80 (Nginx), 3000 (React)"

while true; do
    log_message "--- Escaneando puertos ---"
    
    check_port 22 "SSH"
    check_port 80 "Nginx"
    check_port 3000 "React/Dev"
    
    # Detectar conexiones activas
    CONNECTIONS=$(netstat -tn | grep ESTABLISHED | wc -l)
    log_message "🔗 Conexiones activas: ${CONNECTIONS}"
    
    # Verificar usuarios conectados por SSH
    SSH_USERS=$(who | wc -l)
    if [ "$SSH_USERS" -gt 0 ]; then
        log_message "👤 Usuarios SSH conectados: ${SSH_USERS}"
        who | while read line; do
            log_message "   → ${line}"
        done
    fi
    
    sleep "$SCAN_INTERVAL"
done