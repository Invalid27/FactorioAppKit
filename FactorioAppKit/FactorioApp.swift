import SwiftUI

@main
struct FactorioApp: App {
    var body: some Scene {
        WindowGroup {
            HostedViewController()
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            // Keep your menu commands
        }
    }
}

struct HostedViewController: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    
    func updateNSViewController(_ nsViewController: MainViewController, context: Context) {}
}
