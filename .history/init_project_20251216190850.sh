#!/bin/bash
# init_project.sh - Inicialización con arquitectura en capas
# Construye: ubbase -> ubsecurity -> react-app

SCRIPT_DIR="`$(cd "`$(dirname "`${BASH_SOURCE[0]}")" && pwd)"

echo "[INFO] Detectando estructura de carpetas..."
echo "[INFO] Ruta base: `$SCRIPT_DIR"

# CAPA 1: Construir ubbase (autenticación)
echo ""
echo "[CAPA 1] Construyendo ubbase (Autenticación)..."
cd "`$SCRIPT_DIR" || exit
docker build -t ubbase:latest -f dockerfiles/base/pbase/Dockerfile-pbase .
if [ `$? -ne 0 ]; then 
    echo "[ERROR] Fallo al construir 'ubbase'"; 
    exit 1; 
fi
echo "[OK] Imagen 'ubbase' construida"

# CAPA 2: Construir ubsecurity (ciberseguridad)
echo ""
echo "[CAPA 2] Construyendo ubsecurity (Ciberseguridad)..."
docker build -t ubsecurity:latest -f dockerfiles/base/psecurity/Dockerfile-psecurity .
if [ `$? -ne 0 ]; then 
    echo "[ERROR] Fallo al construir 'ubsecurity'"; 
    exit 1; 
fi
echo "[OK] Imagen 'ubsecurity' construida con scanner de puertos"

# Verificar proyecto React
echo ""
echo "[INFO] Verificando proyecto React..."
if [ ! -d "proyectos/react/src" ]; then
    echo "[ERROR] No se encuentra el código fuente de React en proyectos/react/"
    exit 1
fi
echo "[OK] Proyecto React encontrado"

# CAPA 3: Construir imagen final de React
echo ""
echo "[CAPA 3] Construyendo react-app (Aplicación Final)..."
cd "`$SCRIPT_DIR/proyectos/react" || exit

# Copiar scripts necesarios
echo "[INFO] Copiando scripts de inicio..."
cp "`$SCRIPT_DIR/dockerfiles/personal/react/start.sh" .

# Construir imagen final
docker build -t react-nginx-app -f "`$SCRIPT_DIR/dockerfiles/personal/react/Dockerfile-react" .

if [ `$? -eq 0 ]; then
    echo ""
    echo "[SUCCESS] Arquitectura en capas completada:"
    echo "   [1] ubbase (Autenticación)"
    echo "   [2] ubsecurity (Seguridad + Scanner)"
    echo "   [3] react-nginx-app (Aplicación Web)"
    echo ""
    echo "[NEXT] Ejecuta 'bash deploy.sh' para desplegar"
else
    echo "[ERROR] Fallo al construir la imagen final"
    exit 1
fi
"@ | Out-File -FilePath "init_project.sh" -Encoding UTF8