import Foundation
import IOKit.hid
import CoreGraphics
import AppKit

class MouseController: NSObject {
    private var manager: IOHIDManager
    private var lastButtonState: UInt8 = 0
    var isCommandHeld = false
    var eventTap: CFMachPort?

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    override init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        super.init()

        let criterion: [String: Any] = [
            kIOHIDVendorIDKey: 0x046D,
            kIOHIDProductIDKey: 0xB023
        ]
        IOHIDManagerSetDeviceMatching(manager, criterion as CFDictionary)
        setupMenuBar()
    }

    func setupMenuBar() {
        if let button = statusItem.button {
            button.title = "MX"
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "MX Customizer Activo", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func solicitarPermisos() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Permisos Requeridos"
                alert.informativeText = "MX Customizer necesita permisos de Accesibilidad para que el botón Command funcione.\n\nHaz clic en 'Abrir Ajustes', activa el interruptor de la app y vuelve a abrir MX Customizer."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Abrir Ajustes y Salir")
                alert.addButton(withTitle: "Solo Salir")

                let respuesta = alert.runModal()

                if respuesta == .alertFirstButtonReturn {
                    // Este enlace abre directamente el panel de Accesibilidad en macOS
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
                // Cerramos la app para que el usuario la reinicie tras dar permisos
                NSApplication.shared.terminate(nil)
            }
            return false
        }
        return true
    }

    func start() {
        // Si no hay permisos, la app lanza la alerta, abre ajustes y detiene la ejecución
        if !solicitarPermisos() {
            return
        }

        configurarInterceptorTeclado()

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let callback: IOHIDReportCallback = { (context, result, sender, type, reportId, report, reportLength) in
            let controller = Unmanaged<MouseController>.fromOpaque(context!).takeUnretainedValue()
            let buffer = UnsafeBufferPointer(start: report, count: reportLength)

            if reportId == 2 && buffer.count >= 2 {
                let buttonState = buffer[1]

                if buttonState != controller.lastButtonState {
                    // Soltar boton derecho
                    if controller.lastButtonState == 0x10 && buttonState == 0x00 {
                        controller.isCommandHeld = false
                    }

                    // Boton Izquierdo (0x08)
                    if buttonState == 0x08 {
                        controller.abrirApp(ruta: "/Applications/ClipBoardApp.app")
                    // Boton Derecho (0x10)
                    } else if buttonState == 0x10 {
                        controller.isCommandHeld = true
                    }

                    controller.lastButtonState = buttonState
                }
            }
        }

        IOHIDManagerRegisterInputReportCallback(manager, callback, context)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }



    func configurarInterceptorTeclado() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                        (1 << CGEventType.keyUp.rawValue) |
                        (1 << CGEventType.leftMouseDown.rawValue) |
                        (1 << CGEventType.leftMouseUp.rawValue) |
                        (1 << CGEventType.scrollWheel.rawValue)

        let info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let controller = Unmanaged<MouseController>.fromOpaque(refcon).takeUnretainedValue()

                if controller.isCommandHeld {
                    event.flags.insert(.maskCommand)
                }

                return Unmanaged.passRetained(event)
            },
            userInfo: info
        )

        if let tap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        } else {
            // Si macOS lo bloquea, ahora lo veremos en pantalla
            mostrarAlerta(mensaje: "macOS bloqueo el interceptor del raton. Elimina la app de Accesibilidad y vuelvela a agregar.")
        }
    }

    func abrirApp(ruta: String) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [ruta]
        try? task.run()
    }

    func mostrarAlerta(mensaje: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "MX Customizer"
            alert.informativeText = mensaje
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Entendido")
            alert.runModal()
        }
    }
}

let app = NSApplication.shared
let controller = MouseController()
controller.start()
app.run()
