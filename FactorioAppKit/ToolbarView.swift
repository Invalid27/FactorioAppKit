import Cocoa

// MARK: - Toolbar View
class ToolbarView: NSView {
    weak var graphState: GraphState?
    
    private var aggregateButton: NSPopUpButton!
    private var clearButton: NSButton!
    private var exportButton: NSButton!
    private var importButton: NSButton!
    private var zoomInButton: NSButton!
    private var zoomOutButton: NSButton!
    private var zoomResetButton: NSButton!
    
    init(graphState: GraphState) {
        self.graphState = graphState
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.13, alpha: 1.0).cgColor
        
        // Create stack view for buttons
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Aggregate selector
        aggregateButton = NSPopUpButton()
        aggregateButton.addItems(withTitles: ["Max", "Sum"])
        aggregateButton.selectItem(withTitle: graphState?.aggregate.rawValue ?? "Max")
        aggregateButton.target = self
        aggregateButton.action = #selector(aggregateChanged(_:))
        stackView.addArrangedSubview(aggregateButton)
        
        // Separator
        let separator1 = NSBox()
        separator1.boxType = .separator
        stackView.addArrangedSubview(separator1)
        
        // Clear button
        clearButton = NSButton(title: "Clear", target: self, action: #selector(clearGraph))
        clearButton.bezelStyle = .rounded
        stackView.addArrangedSubview(clearButton)
        
        // Separator
        let separator2 = NSBox()
        separator2.boxType = .separator
        stackView.addArrangedSubview(separator2)
        
        // Export/Import buttons
        exportButton = NSButton(title: "Export", target: self, action: #selector(exportGraph))
        exportButton.bezelStyle = .rounded
        stackView.addArrangedSubview(exportButton)
        
        importButton = NSButton(title: "Import", target: self, action: #selector(importGraph))
        importButton.bezelStyle = .rounded
        stackView.addArrangedSubview(importButton)
        
        // Spacer
        let spacer = NSView()
        stackView.addArrangedSubview(spacer)
        
        // Zoom controls
        let zoomStack = NSStackView()
        zoomStack.orientation = .horizontal
        zoomStack.spacing = 8
        
        zoomOutButton = NSButton(image: NSImage(systemSymbolName: "minus.magnifyingglass", accessibilityDescription: nil)!, target: self, action: #selector(zoomOut))
        zoomOutButton.bezelStyle = .rounded
        zoomStack.addArrangedSubview(zoomOutButton)
        
        zoomResetButton = NSButton(image: NSImage(systemSymbolName: "1.magnifyingglass", accessibilityDescription: nil)!, target: self, action: #selector(zoomReset))
        zoomResetButton.bezelStyle = .rounded
        zoomStack.addArrangedSubview(zoomResetButton)
        
        zoomInButton = NSButton(image: NSImage(systemSymbolName: "plus.magnifyingglass", accessibilityDescription: nil)!, target: self, action: #selector(zoomIn))
        zoomInButton.bezelStyle = .rounded
        zoomStack.addArrangedSubview(zoomInButton)
        
        stackView.addArrangedSubview(zoomStack)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        
        // Add bottom border
        let border = NSBox()
        border.boxType = .separator
        border.translatesAutoresizingMaskIntoConstraints = false
        addSubview(border)
        
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
            border.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func aggregateChanged(_ sender: NSPopUpButton) {
        if let title = sender.selectedItem?.title,
           let aggregate = GraphState.Aggregate(rawValue: title) {
            graphState?.aggregate = aggregate
        }
    }
    
    @objc private func clearGraph() {
        let alert = NSAlert()
        alert.messageText = "Clear Graph"
        alert.informativeText = "Are you sure you want to clear everything?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            graphState?.clearGraph()
        }
    }
    
    @objc private func exportGraph() {
        graphState?.exportJSON(from: window)
    }
    
    @objc private func importGraph() {
        graphState?.importJSON(from: window)
    }
    
    @objc private func zoomIn() {
        graphState?.zoomIn()
    }
    
    @objc private func zoomOut() {
        graphState?.zoomOut()
    }
    
    @objc private func zoomReset() {
        graphState?.resetZoom()
    }
}
