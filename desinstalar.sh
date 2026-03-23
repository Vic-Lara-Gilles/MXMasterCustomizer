#!/bin/bash
set -e

BUNDLE_ID="com.victor.mxcustomizer"
APP_PATH="/Applications/MXCustomizer.app"

echo "=== Desinstalando MXCustomizer ==="

# 1. Cerrar la app si está en ejecución
echo "-> Cerrando MXCustomizer..."
pkill -x "MXCustomizer" 2>/dev/null && echo "   App cerrada." || echo "   App no estaba en ejecución (omitido)."

# 3. Revocar todos los permisos TCC (Accesibilidad, etc.)
echo "-> Revocando permisos del sistema..."
tccutil reset All "$BUNDLE_ID" 2>/dev/null && echo "   Permisos revocados." || echo "   Sin permisos registrados (omitido)."

# 4. Eliminar la app de /Applications
if [ -d "$APP_PATH" ]; then
    rm -rf "$APP_PATH"
    echo "-> App eliminada: $APP_PATH"
else
    echo "-> App no encontrada en /Applications (omitido)."
fi

echo ""
echo "Desinstalación completada."
