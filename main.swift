import Foundation
import IOKit.hid
import CoreGraphics

class MouseController {
    private var manager: IOHIDManager
    private var lastButtonState: UInt8 = 0
    
    // Variable para saber si el boton derecho esta siendo mantenido
    var isCommandHeld = false
    var eventTap: CFMachPort?

    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        let criterion: [String: Any] = [
            kIOHIDVendorIDKey: 0x046D,
            kIOHIDProductIDKey: 0xB023
        ]
        IOHIDManagerSetDeviceMatching(manager, criterion as CFDictionary)
    }

    func start() {
        // Iniciamos el interceptor de teclado y clics
        configurarInterceptorTeclado()
        
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let callback: IOHIDReportCallback = { (context, result, sender, type, reportId, report, reportLength) in
            let controller = Unmanaged<MouseController>.fromOpaque(context!).takeUnretainedValue()
            let buffer = UnsafeBufferPointer(start: report, count: reportLength)
            
            if reportId == 2 && buffer.count >= 2 {
                let buttonState = buffer[1]
                
                if buttonState != controller.lastButtonState {
                    
                    // Al soltar el boton, desactivamos el estado Command
                    if controller.lastButtonState == 0x10 && buttonState == 0x00 {
                        print("Soltando boton: Command desactivado")
                        controller.isCommandHeld = false
                    }
                    
                    // Boton Izquierdo (0x08) -> Abre la App
                    if buttonState == 0x08 {
                        print("Accion: Abriendo ClipBoardApp")
                        controller.abrirApp(ruta: "/Applications/ClipBoardApp.app")
                        
                    // Boton Derecho (0x10) -> Activa estado Command
                    } else if buttonState == 0x10 {
                        print("Boton presionado: Command activado")
                        controller.isCommandHeld = true
                    }
                    
                    controller.lastButtonState = buttonState
                }
            }
        }

        IOHIDManagerRegisterInputReportCallback(manager, callback, context)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        
        let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        
        if openResult == kIOReturnSuccess {
            print("Programa iniciado. Izquierdo: Abre App. Derecho: Actua como Command.")
        } else {
            print("Error al abrir el dispositivo.")
        }
    }
    
    // Intercepta los eventos del sistema
    func configurarInterceptorTeclado() {
        // Escuchamos teclas y clics del mouse
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
                
                // Si el boton del mouse esta presionado, agregamos Command a la accion
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
            print("Advertencia: No se pudo crear el EventTap. Revisa los permisos de Accesibilidad.")
        }
    }

    func abrirApp(ruta: String) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [ruta]
        
        do {
            try task.run()
        } catch {
            print("Error al intentar abrir la app: \(error)")
        }
    }
}

let controller = MouseController()
controller.start()

RunLoop.main.run()
