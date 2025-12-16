#!/bin/bash
# start.sh - Script de inicio para aplicación React con seguridad

echo "[INFO] Iniciando aplicación React con seguridad..."

# 1. Cargar configuración de usuarios si existe
if [ -f /root/admin/base/usuarios/mainusuarios.sh ]; then
    echo "[INFO] Cargando configuración de usuarios..."
    source /root/admin/base/usuarios/mainusuarios.sh
fi

# 2. Iniciar scanner de seguridad en segundo plano
if [ -f /root/security/port-scanner.sh ] && [ "$ENABLE_SECURITY" != "false" ]; then
    echo "[INFO] Iniciando scanner de seguridad..."
    /root/security/port-scanner.sh &
    echo "[INFO] Scanner de puertos activado (monitoreando 22, 80, 3000)"
fi

# 3. Iniciar Nginx en segundo plano
if [ "$ENABLE_NGINX" != "false" ]; then
    echo "[INFO] Iniciando Nginx..."
    service nginx start
    
    # Verificar que Nginx arrancó correctamente
    if nginx -t 2>/dev/null; then
        echo "[OK] Nginx configurado correctamente"
    else
        echo "[WARNING] Nginx tiene problemas de configuración"
    fi
fi

# 4. Iniciar SSH en primer plano (mantiene contenedor vivo)
echo "[INFO] Iniciando SSH..."
mkdir -p /run/sshd
echo "[OK] Todos los servicios iniciados - Contenedor activo"
exec /usr/sbin/sshd -D