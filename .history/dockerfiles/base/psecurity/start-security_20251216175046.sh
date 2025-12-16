#!/bin/bash
# start-security.sh - Inicia servicios base + scanner de seguridad

# Ejecutar script de inicio de la capa base (usuarios, SSH)
if [ -f /root/admin/base/start.sh ]; then
    echo "🔧 Cargando configuración base (usuarios y SSH)..."
    source /root/admin/base/start.sh &
    BASE_PID=$!
fi

# Iniciar scanner de puertos en segundo plano
if [ "$ENABLE_PORT_SCANNER" != "false" ]; then
    echo "🔒 Iniciando scanner de seguridad..."
    /root/security/port-scanner.sh &
    SCANNER_PID=$!
    echo "📡 Scanner PID: $SCANNER_PID"
fi

# Mantener contenedor vivo
echo "✅ Servicios de seguridad iniciados"
tail -f /dev/null