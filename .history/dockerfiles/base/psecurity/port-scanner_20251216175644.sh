#!/bin/bash
# port-scanner.sh - Monitor de seguridad de puertos
# Monitorea puertos 22 (SSH), 80 (Nginx), 3000 (React)

# Archivo donde se guardan los logs
LOG_FILE="/var/log/port-scanner.log"
# Tiempo en segundos entre cada escaneo
SCAN_INTERVAL=60

# Crear archivo de log si no existe
touch "$LOG_FILE"

# Función para escribir mensajes en el log y en pantalla
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función que verifica si un puerto está activo
check_port() {
    local port=$1      # Número de puerto a verificar
    local service=$2   # Nombre del servicio
    
    # netstat busca el puerto en la lista de puertos abiertos
    if netstat -tuln | grep -q ":${port} "; then
        log_message "Puerto ${port} (${service}): ACTIVO"
        return 0
    else
        log_message "Puerto ${port} (${service}): INACTIVO - ALERTA"
        return 1
    fi
}

# Mensaje de inicio
log_message "🔒 Iniciando scanner de seguridad..."
log_message "📡 Monitoreando puertos: 22 (SSH), 80 (Nginx), 3000 (React)"

# Bucle infinito que escanea continuamente
while true; do
    log_message "--- Escaneando puertos ---"
    
    # Verificar cada puerto
    check_port 22 "SSH"
    check_port 80 "Nginx"
    check_port 3000 "React/Dev"
    
    # Contar cuántas conexiones activas hay
    CONNECTIONS=$(netstat -tn | grep ESTABLISHED | wc -l)
    log_message "🔗 Conexiones activas: ${CONNECTIONS}"
    
    # Ver si hay usuarios conectados por SSH
    SSH_USERS=$(who | wc -l)
    if [ "$SSH_USERS" -gt 0 ]; then
        log_message "👤 Usuarios SSH conectados: ${SSH_USERS}"
        # Listar cada usuario conectado
        who | while read line; do
            log_message "   → ${line}"
        done
    fi
    
    # Esperar antes del próximo escaneo
    sleep "$SCAN_INTERVAL"
done