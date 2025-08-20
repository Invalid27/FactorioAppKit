import Cocoa

class WindowController: NSWindowController {
    
    override init(window: NSWindow?) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Factorio Planner"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        
        // Add these to ensure window is visible
        window.isReleasedWhenClosed = false
        window.level = .normal
        
        super.init(window: window)
        
        let viewController = MainViewController()
        window.contentViewController = viewController
        
        // Make sure the window is visible
        window.makeKeyAndOrderFront(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Override showWindow to ensure it's visible
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
    }
}
