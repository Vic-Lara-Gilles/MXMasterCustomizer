# MX Master 3 Customizer (macOS Swift)

Este software permite personalizar los botones laterales del mouse **Logitech MX Master 3** en macOS (específicamente probado en Apple Silicon M1) utilizando Swift, IOKit y AppKit, sin necesidad de instalar Logi Options+.

## Funcionalidades Actuales
* **Botón Lateral Izquierdo (Retroceso):** Abre la aplicación `ClipBoardApp.app`.
* **Botón Lateral Derecho (Avance):** Actúa como la tecla **Command (⌘)** global. Mientras se mantiene presionado, cualquier otra tecla o clic del mouse incluirá la bandera de Command.
* **Icono en la barra de menú:** La app muestra un indicador `MX` en la barra de menú con un menú de estado y opción de salir.
* **Alertas visuales de permisos:** Si la app no tiene permisos de Accesibilidad, muestra un diálogo nativo que guía al usuario a *Ajustes del Sistema* y cierra la app para que los permisos surtan efecto.

## Requisitos Técnicos
* **macOS 12.0** o superior.
* **Swift 5.0+** instalado (viene con Xcode Command Line Tools).
* **Permisos de Accesibilidad:** La app debe ser autorizada en *Ajustes del Sistema > Privacidad y Seguridad > Accesibilidad*. Al primer inicio sin permisos, la app mostrará una alerta y abrirá el panel correspondiente automáticamente.

## Instalación (Bundle .app)

El script `compilar.sh` compila el código y crea la app directamente en `/Applications/`:

```bash
chmod +x compilar.sh
./compilar.sh
```

Esto genera `MXCustomizer.app` con su `Info.plist` y la mueve a `/Applications/MXCustomizer.app`.

Tras la primera ejecución, ve a **Ajustes del Sistema > Privacidad y Seguridad > Accesibilidad** y activa `MXCustomizer`. Vuelve a abrir la app para que funcione correctamente.

## Desinstalación

Para eliminar completamente la app y revocar sus permisos del sistema:

```bash
chmod +x desinstalar.sh
./desinstalar.sh
```

El script cierra la app si está en ejecución, revoca sus permisos de Accesibilidad (TCC) y elimina el bundle de `/Applications`.

## Identificador de Bundle
* **Bundle ID:** `com.victor.mxcustomizer`

## Logs de Monitoreo
Puedes revisar el estado del servicio en tiempo real en:
* `/tmp/mxmaster.log`
* `/tmp/mxmaster_error.log`
