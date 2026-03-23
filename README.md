# MX Master 3 Customizer (macOS Swift)

Este software permite personalizar los botones laterales del mouse **Logitech MX Master 3** en macOS (específicamente probado en Apple Silicon M1) utilizando Swift e IOKit, sin necesidad de instalar Logi Options+.

## Funcionalidades Actuales
* **Botón Lateral Izquierdo (Retroceso):** Abre la aplicación `ClipBoardApp.app`.
* **Botón Lateral Derecho (Avance):** Actúa como la tecla **Command (⌘)** global. Mientras se mantiene presionado, cualquier otra tecla o clic del mouse incluirá la bandera de Command.

## Requisitos Técnicos
* **macOS 12.0** o superior.
* **Swift 5.0+** instalado (viene con Xcode Command Line Tools).
* **Permisos de Accesibilidad:** El binario requiere ser autorizado en *Ajustes del Sistema > Privacidad y Seguridad > Accesibilidad*.
* **Monitorización de Entrada:** Requerido para interceptar los eventos del mouse y teclado.

## Instalación y Compilación Manual

1.  **Compilar el código:**
    ```bash
    swiftc main.swift -o MXCustomizer
    ```

2.  **Ejecución de prueba:**
    ```bash
    sudo ./MXCustomizer
    ```

## Configuración como Servicio del Sistema (Auto-inicio)

Para que el programa se inicie automáticamente al encender el Mac, se utiliza un `LaunchDaemon`:

1.  Mover el binario a la ruta del sistema:
    ```bash
    sudo cp MXCustomizer /usr/local/bin/MXCustomizer
    ```
2.  Cargar el servicio (asumiendo que el archivo `.plist` ha sido creado en `/Library/LaunchDaemons/`):
    ```bash
    sudo launchctl load /Library/LaunchDaemons/com.custom.mxmaster.plist
    ```

## Seguridad y Blindaje
El ejecutable ha sido blindado para evitar manipulaciones maliciosas dado que corre con privilegios de `root`:

* **Propietario:** `root:wheel`
* **Permisos:** `755` (Solo root puede modificar).
* **Inmutabilidad:** Se ha aplicado el flag `uchg` para evitar sobrescritura accidental.

> **Nota:** Para actualizar el software, primero debes quitar el flag de inmutabilidad: 
> `sudo chflags nouchg /usr/local/bin/MXCustomizer`

## Logs de Monitoreo
Puedes revisar el estado del servicio en tiempo real en:
* `/tmp/mxmaster.log`
* `/tmp/mxmaster_error.log`
