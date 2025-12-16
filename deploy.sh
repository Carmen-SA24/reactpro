#!/bin/bash
# deploy.sh - Despliegue con arquitectura en capas
# Actualiza repositorio y redespliega con Docker Compose

echo "[INFO] Iniciando Despliegue..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Actualizar repositorio
echo ""
echo "[STEP 1] Actualizando repositorio..."
cd "$SCRIPT_DIR" || exit
git pull origin main

# 2. Reconstruir imágenes base si hay cambios
echo ""
echo "[STEP 2] Verificando capas base..."

# Reconstruir ubbase
echo "[INFO] Actualizando ubbase..."
docker build -t ubbase:latest -f dockerfiles/base/pbase/Dockerfile-pbase . --quiet

# Reconstruir ubsecurity
echo "[INFO] Actualizando ubsecurity (con scanner)..."
docker build -t ubsecurity:latest -f dockerfiles/base/psecurity/Dockerfile-psecurity . --quiet

# 3. Preparar contexto de build
echo ""
echo "[STEP 3] Preparando archivos de aplicación..."
cd "$SCRIPT_DIR/proyectos/react" || exit

# Copiar start.sh actualizado
if [ -f "$SCRIPT_DIR/dockerfiles/personal/react/start.sh" ]; then
    cp "$SCRIPT_DIR/dockerfiles/personal/react/start.sh" .
    echo "[OK] start.sh copiado"
else
    echo "[WARNING] No se encontró start.sh"
fi

# 4. Desplegar con Docker Compose
echo ""
echo "[STEP 4] Desplegando contenedores..."
docker compose down --rmi all 2>/dev/null || true
docker compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "[SUCCESS] Despliegue Completado"
    echo ""
    echo "[INFO] Estado de servicios:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "[INFO] Aplicación disponible en:"
    echo "   Web:  http://[TU-IP]:3000"
    echo "   SSH:  ssh -p 2222 maria@[TU-IP]"
    echo ""
    echo "[INFO] Ver logs del scanner:"
    echo "   docker exec -it react-web-container tail -f /var/log/port-scanner.log"
else
    echo "[ERROR] Falló el despliegue"
    exit 1
fi