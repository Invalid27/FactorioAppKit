import Cocoa

// MARK: - Main View Controller
class MainViewController: NSViewController {
    let graphState = GraphState()
    let machinePreferences = MachinePreferences.load()
    
    var canvasView: CanvasView!
    var toolbar: ToolbarView!
    var splitView: NSSplitView!
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        
        // Load auto-saved state
        graphState.loadAutoSave()
    }
    
    private func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(white: 0.11, alpha: 1.0).cgColor
        
        // Create toolbar
        toolbar = ToolbarView(graphState: graphState)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        // Create canvas
        canvasView = CanvasView(graphState: graphState)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 48),
            
            canvasView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Set up menu items
        setupMenus()
        
        // Monitor for keyboard shortcuts
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            // Handle keyboard shortcuts
            if event.modifierFlags.contains(.command) {
                switch event.charactersIgnoringModifiers {
                case "f":
                    self.showGeneralRecipePicker()
                    return nil
                case "0":
                    self.graphState.resetZoom()
                    return nil
                case "x":
                    if self.graphState.selectedNodeID != nil {
                        self.graphState.cutNode()
                        return nil
                    }
                case "c":
                    if self.graphState.selectedNodeID != nil {
                        self.graphState.copyNode()
                        return nil
                    }
                case "v":
                    if self.graphState.clipboard != nil {
                        self.graphState.pasteNode()
                        return nil
                    }
                default:
                    break
                }
            } else if event.keyCode == 51 { // Delete key
                self.graphState.deleteSelectedNodes()
                return nil
            }
            
            return event
        }
    }
    
    private func setupMenus() {
        // Set up application menu
        let mainMenu = NSApplication.shared.mainMenu ?? NSMenu()
        
        // Edit menu
        if let editMenu = mainMenu.item(withTitle: "Edit")?.submenu {
            editMenu.removeAllItems()
            
            editMenu.addItem(withTitle: "Cut", action: #selector(cut(_:)), keyEquivalent: "x")
            editMenu.addItem(withTitle: "Copy", action: #selector(copy(_:)), keyEquivalent: "c")
            editMenu.addItem(withTitle: "Paste", action: #selector(paste(_:)), keyEquivalent: "v")
            editMenu.addItem(NSMenuItem.separator())
            editMenu.addItem(withTitle: "Delete", action: #selector(deleteSelection), keyEquivalent: "")
        }
        
        // File menu
        if let fileMenu = mainMenu.item(withTitle: "File")?.submenu {
            fileMenu.insertItem(withTitle: "Export...", action: #selector(exportGraph), keyEquivalent: "e", at: 1)
            fileMenu.insertItem(withTitle: "Import...", action: #selector(importGraph), keyEquivalent: "i", at: 2)
            fileMenu.insertItem(NSMenuItem.separator(), at: 3)
        }
    }
    
    // MARK: - Actions
    @objc private func cut(_ sender: Any?) {
        graphState.cutNode()
    }
    
    @objc private func copy(_ sender: Any?) {
        graphState.copyNode()
    }
    
    @objc private func paste(_ sender: Any?) {
        graphState.pasteNode()
    }
    
    @objc private func deleteSelection() {
        graphState.deleteSelectedNodes()
    }
    
    @objc private func exportGraph() {
        graphState.exportJSON(from: view.window)
    }
    
    @objc private func importGraph() {
        graphState.importJSON(from: view.window)
    }
    
    private func showGeneralRecipePicker() {
        let pickerWindow = GeneralRecipePickerWindow(graphState: graphState)
        view.window?.beginSheet(pickerWindow)
    }
}

