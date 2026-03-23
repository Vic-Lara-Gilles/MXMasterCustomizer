#!/bin/bash
set -e

# Crear estructura de la App
mkdir -p MXCustomizer.app/Contents/MacOS

# Crear el archivo de configuración de la App
cat << 'EOF' > MXCustomizer.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MXCustomizer</string>
    <key>CFBundleIdentifier</key>
    <string>com.victor.mxcustomizer</string>
    <key>CFBundleName</key>
    <string>MXCustomizer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Compilar el código directamente dentro de la App
swiftc main.swift -o MXCustomizer.app/Contents/MacOS/MXCustomizer

# Mover la App a tu carpeta oficial de Aplicaciones
rm -rf /Applications/MXCustomizer.app
mv MXCustomizer.app /Applications/

echo "MXCustomizer.app creada y movida a /Applications"
