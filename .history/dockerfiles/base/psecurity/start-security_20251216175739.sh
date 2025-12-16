#!/bin/bash
# start-security.sh - Inicia servicios base + scanner de seguridad

# Ejecutar script de inicio de la capa base (usuarios, SSH)
if [ -f /root/admin/base/start.sh ]; then
    echo "[INFO] Cargando configuración base (usuarios y SSH)..."
    source /root/admin/base/start.sh &
    BASE_PID=$!
fi

# Iniciar scanner de puertos en segundo plano
if [ "$ENABLE_PORT_SCANNER" != "false" ]; then
    echo "[INFO] Iniciando scanner de seguridad..."
    /root/security/port-scanner.sh &
    SCANNER_PID=$!
    echo "[INFO] Scanner PID: $SCANNER_PID"
fi

# Mantener contenedor vivo
echo "[OK] Servicios de seguridad iniciados"
tail -f /dev/null