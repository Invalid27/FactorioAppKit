import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: WindowController?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // This ensures your app runs as a regular GUI app
        NSApp.setActivationPolicy(.regular)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        windowController = WindowController()
        windowController?.showWindow(nil)
        
        // Force the window to appear
        windowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
