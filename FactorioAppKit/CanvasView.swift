import Cocoa
import Combine

// MARK: - Canvas View
class CanvasView: NSView {
    weak var graphState: GraphState?
    private var cancellables = Set<AnyCancellable>()
    
    // Interaction state
    private var isDraggingNode = false
    private var draggedNodeID: UUID?
    private var dragOffset: NSPoint = .zero
    private var isDraggingWire = false
    private var wireStart: (nodeID: UUID, portID: UUID, point: NSPoint)?
    private var wireEnd: NSPoint = .zero
    private var isBoxSelecting = false
    private var selectionStart: NSPoint = .zero
    private var selectionEnd: NSPoint = .zero
    private var isPanning = false
    private var panStart: NSPoint = .zero
    private var tempPanOffset: NSSize = .zero
    
    // Tracking
    private var trackingArea: NSTrackingArea?
    private var lastMousePosition: NSPoint = .zero
    
    init(graphState: GraphState) {
        self.graphState = graphState
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.11, alpha: 1.0).cgColor
        
        // Enable mouse tracking
        updateTrackingAreas()
    }
    
    override func updateTrackingAreas() {
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }
    
    private func setupBindings() {
        guard let graphState = graphState else { return }
        
        // Subscribe to graph state changes
        graphState.$nodes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        graphState.$edges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        graphState.$selectedNodeID
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        graphState.$selectedNodeIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        graphState.$canvasScale
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        graphState.$canvasOffset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Drawing
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext,
              let graphState = graphState else { return }
        
        // Draw grid
        drawGrid(in: context)
        
        // Draw edges/wires
        drawEdges(in: context)
        
        // Draw nodes
        drawNodes(in: context)
        
        // Draw drag wire if dragging
        if isDraggingWire, let start = wireStart {
            drawDragWire(from: start.point, to: wireEnd, in: context)
        }
        
        // Draw selection box if selecting
        if isBoxSelecting {
            drawSelectionBox(in: context)
        }
    }
    
    private func drawGrid(in context: CGContext) {
        guard let graphState = graphState else { return }
        
        let scale = graphState.canvasScale
        let offset = NSSize(
            width: graphState.canvasOffset.width + tempPanOffset.width,
            height: graphState.canvasOffset.height + tempPanOffset.height
        )
        
        context.saveGState()
        
        // Apply transform
        context.translateBy(x: offset.width, y: offset.height)
        context.scaleBy(x: scale, y: scale)
        
        // Draw grid dots
        let spacing = Constants.gridSpacing
        let dotSize = Constants.dotSize
        
        let startX = -offset.width / scale - spacing
        let endX = (bounds.width - offset.width) / scale + spacing
        let startY = -offset.height / scale - spacing
        let endY = (bounds.height - offset.height) / scale + spacing
        
        context.setFillColor(NSColor.white.withAlphaComponent(0.05).cgColor)
        
        for x in stride(from: startX - startX.truncatingRemainder(dividingBy: spacing),
                       through: endX, by: spacing) {
            for y in stride(from: startY - startY.truncatingRemainder(dividingBy: spacing),
                           through: endY, by: spacing) {
                let rect = CGRect(x: x - dotSize/2, y: y - dotSize/2,
                                 width: dotSize, height: dotSize)
                context.fillEllipse(in: rect)
            }
        }
        
        context.restoreGState()
    }
    
    private func drawNodes(in context: CGContext) {
        guard let graphState = graphState else { return }
        
        let scale = graphState.canvasScale
        let offset = NSSize(
            width: graphState.canvasOffset.width + tempPanOffset.width,
            height: graphState.canvasOffset.height + tempPanOffset.height
        )
        
        for node in graphState.nodes.values {
            let isSelected = graphState.selectedNodeID == node.id ||
                           graphState.selectedNodeIDs.contains(node.id)
            
            drawNode(node, isSelected: isSelected, scale: scale, offset: offset, in: context)
        }
    }
    
    private func drawNode(_ node: Node, isSelected: Bool, scale: CGFloat, offset: NSSize, in context: CGContext) {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else { return }
        
        context.saveGState()
        
        // Calculate node position with transform
        let nodeX = node.x * scale + offset.width
        let nodeY = node.y * scale + offset.height
        let nodeWidth = Constants.nodeMinWidth * scale
        let nodeHeight = Constants.nodeHeight * scale
        
        let nodeRect = CGRect(
            x: nodeX - nodeWidth/2,
            y: nodeY - nodeHeight/2,
            width: nodeWidth,
            height: nodeHeight
        )
        
        // Draw node background
        let path = CGPath(roundedRect: nodeRect, cornerWidth: 8, cornerHeight: 8, transform: nil)
        context.addPath(path)
        context.setFillColor(NSColor.black.withAlphaComponent(isSelected ? 0.25 : 0.20).cgColor)
        context.fillPath()
        
        // Draw node border
        context.addPath(path)
        if isSelected {
            context.setStrokeColor(NSColor.orange.withAlphaComponent(0.4).cgColor)
            context.setLineWidth(1.5)
        } else {
            context.setStrokeColor(NSColor.white.withAlphaComponent(0.05).cgColor)
            context.setLineWidth(1)
        }
        context.strokePath()
        
        // Draw node content
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        
        // Draw title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12 * scale, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        
        let title = recipe.name as NSString
        let titleSize = title.size(withAttributes: titleAttrs)
        title.draw(at: NSPoint(x: nodeX - titleSize.width/2,
                               y: nodeY + nodeHeight/2 - titleSize.height - 5 * scale),
                  withAttributes: titleAttrs)
        
        // Draw production rate if set
        if let rate = node.targetPerMin, rate > 0 {
            let rateText = String(format: "%.1f/min", rate) as NSString
            let rateAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11 * scale, weight: .bold),
                .foregroundColor: NSColor.green
            ]
            let rateSize = rateText.size(withAttributes: rateAttrs)
            rateText.draw(at: NSPoint(x: nodeX - rateSize.width/2,
                                     y: nodeY - rateSize.height/2),
                        withAttributes: rateAttrs)
        }
        
        // Draw machine icon
        if let selectedTier = getSelectedMachineTier(for: node),
           let iconName = selectedTier.iconAsset,
           let icon = NSImage(named: iconName) {
            let iconSize = Constants.iconSize * scale
            let iconRect = NSRect(x: nodeX - iconSize/2,
                                 y: nodeY - nodeHeight/2 + 25 * scale,
                                 width: iconSize, height: iconSize)
            icon.draw(in: iconRect)
        }
        
        NSGraphicsContext.restoreGraphicsState()
        
        // Draw ports
        drawPorts(for: node, at: NSPoint(x: nodeX, y: nodeY),
                 scale: scale, in: context)
        
        context.restoreGState()
    }
    
    private func drawPorts(for node: Node, at position: NSPoint, scale: CGFloat, in context: CGContext) {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else { return }
        
        let nodeWidth = Constants.nodeMinWidth * scale
        
        // Calculate spacing based on number of ports
        let maxInputs = recipe.inputs.count
        let maxOutputs = recipe.outputs.count
        let maxPorts = max(maxInputs, maxOutputs)
        
        // Adjust spacing to fit all ports within node height
        let portHeight: CGFloat = 24 * scale
        let portSpacing: CGFloat = 8 * scale
        let totalPortsHeight = CGFloat(maxPorts) * portHeight + CGFloat(maxPorts - 1) * portSpacing
        let startY = totalPortsHeight / 2
        
        // Save graphics state for drawing
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        
        // Draw input ports (left side)
        for (index, (itemName, amount)) in recipe.inputs.enumerated() {
            let yOffset = startY - CGFloat(index) * (portHeight + portSpacing)
            let portPosition = NSPoint(
                x: position.x - nodeWidth/2 + 5 * scale,
                y: position.y + yOffset - portHeight/2
            )
            
            // Check if connected for visual feedback
            let isConnected = graphState?.edges.contains { edge in
                edge.toNode == node.id && edge.item == itemName
            } ?? false
            
            drawPortBadge(item: itemName, amount: amount, at: portPosition,
                         isInput: true, isConnected: isConnected,
                         width: 60 * scale, height: portHeight,
                         scale: scale, in: context)
        }
        
        // Draw output ports (right side)
        for (index, (itemName, amount)) in recipe.outputs.enumerated() {
            let yOffset = startY - CGFloat(index) * (portHeight + portSpacing)
            let portWidth: CGFloat = 60 * scale
            let portPosition = NSPoint(
                x: position.x + nodeWidth/2 - portWidth - 5 * scale,
                y: position.y + yOffset - portHeight/2
            )
            
            // Check if connected for visual feedback
            let isConnected = graphState?.edges.contains { edge in
                edge.fromNode == node.id && edge.item == itemName
            } ?? false
            
            drawPortBadge(item: itemName, amount: amount, at: portPosition,
                         isInput: false, isConnected: isConnected,
                         width: portWidth, height: portHeight,
                         scale: scale, in: context)
        }
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
    private func drawPortBadge(item: String, amount: Double, at position: NSPoint,
                               isInput: Bool, isConnected: Bool,
                               width: CGFloat, height: CGFloat,
                               scale: CGFloat, in context: CGContext) {
        let rect = NSRect(x: position.x, y: position.y, width: width, height: height)
        
        // Draw background with gradient
        let path = NSBezierPath(roundedRect: rect, xRadius: height/2, yRadius: height/2)
        
        context.saveGState()
        
        // Create gradient based on port type and connection status
        let baseColor: NSColor
        let textColor: NSColor
        
        if isInput {
            // Input ports - darker brownish
            if isConnected {
                baseColor = NSColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
            } else {
                baseColor = NSColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
            }
            textColor = NSColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0)
        } else {
            // Output ports - lighter brownish
            if isConnected {
                baseColor = NSColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 1.0)
            } else {
                baseColor = NSColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
            }
            textColor = NSColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
        }
        
        // Draw gradient background
        if let gradient = NSGradient(colors: [
            baseColor.blended(withFraction: 0.2, of: .white) ?? baseColor,
            baseColor,
            baseColor.blended(withFraction: 0.2, of: .black) ?? baseColor
        ]) {
            gradient.draw(in: path, angle: -90)
        }
        
        // Draw subtle border
        context.setStrokeColor(NSColor.black.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5 * scale)
        context.addPath(path.cgPath)
        context.strokePath()
        
        context.restoreGState()
        
        // Draw amount and icon
        let iconSize = height * 0.7
        let padding = height * 0.15
        
        // Draw amount text (e.g., "2×")
        let amountText: String
        if amount == Double(Int(amount)) {
            amountText = "\(Int(amount))×"
        } else {
            amountText = String(format: "%.1f×", amount)
        }
        
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10 * scale, weight: .medium),
            .foregroundColor: textColor
        ]
        
        let textString = NSAttributedString(string: amountText, attributes: textAttrs)
        let textSize = textString.size()
        
        // Position text on the left side of the badge
        let textX = position.x + padding
        let textY = position.y + (height - textSize.height) / 2
        textString.draw(at: NSPoint(x: textX, y: textY))
        
        // Try to get and draw the icon
        let iconName = getIconName(for: item)
        
        // Debug print to see what icon names we're looking for
        print("Looking for icon: '\(iconName)' for item: '\(item)'")
        
        if let icon = NSImage(named: iconName) {
            // Position icon on the right side of the badge
            let iconRect = NSRect(
                x: position.x + width - iconSize - padding,
                y: position.y + (height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            icon.draw(in: iconRect)
        } else {
            // Try alternate icon naming (with spaces replaced by hyphens)
            let alternateIconName = item.replacingOccurrences(of: " ", with: "-").lowercased()
            if let icon = NSImage(named: alternateIconName) {
                let iconRect = NSRect(
                    x: position.x + width - iconSize - padding,
                    y: position.y + (height - iconSize) / 2,
                    width: iconSize,
                    height: iconSize
                )
                icon.draw(in: iconRect)
            } else {
                // If still no icon available, show item name in smaller text
                let itemTextAttrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 7 * scale, weight: .regular),
                    .foregroundColor: textColor.withAlphaComponent(0.7)
                ]
                
                let itemString = NSAttributedString(string: item, attributes: itemTextAttrs)
                let itemTextSize = itemString.size()
                
                // Position item name after the amount
                let itemX = textX + textSize.width + 4 * scale
                let itemY = position.y + (height - itemTextSize.height) / 2
                
                // Only draw if it fits
                if itemX + itemTextSize.width < position.x + width - padding {
                    itemString.draw(at: NSPoint(x: itemX, y: itemY))
                }
            }
        }
    }

    
    // Helper function to get icon name from item name
    private func getIconName(for item: String) -> String {
        // First, try to normalize the item name by converting to lowercase and replacing spaces with hyphens
        let normalizedItem = item.replacingOccurrences(of: " ", with: "-").lowercased()
        
        // This maps item names to their icon asset names
        // Using the normalized format that should match your asset names
        switch normalizedItem {
        // Ores
        case "iron-ore": return "iron-ore"
        case "copper-ore": return "copper-ore"
        case "coal": return "coal"
        case "stone": return "stone"
        case "uranium-ore": return "uranium-ore"
        
        // Plates
        case "iron-plate": return "iron-plate"
        case "copper-plate": return "copper-plate"
        case "steel-plate": return "steel-plate"
        
        // Intermediate products
        case "iron-gear-wheel": return "iron-gear-wheel"
        case "copper-cable": return "copper-cable"
        case "electronic-circuit", "green-circuit": return "electronic-circuit"
        case "advanced-circuit", "red-circuit": return "advanced-circuit"
        case "processing-unit", "blue-circuit": return "processing-unit"
        case "plastic-bar", "plastic": return "plastic-bar"
        case "sulfur": return "sulfur"
        case "battery": return "battery"
        case "engine-unit": return "engine-unit"
        case "electric-engine-unit": return "electric-engine-unit"
        case "flying-robot-frame": return "flying-robot-frame"
        case "low-density-structure": return "low-density-structure"
        case "rocket-fuel": return "rocket-fuel"
        case "rocket-control-unit": return "rocket-control-unit"
        case "satellite": return "satellite"
        case "uranium-235": return "uranium-235"
        case "uranium-238": return "uranium-238"
        case "nuclear-fuel": return "nuclear-fuel"
        
        // Fluids
        case "water": return "water"
        case "crude-oil": return "crude-oil"
        case "heavy-oil": return "heavy-oil"
        case "light-oil": return "light-oil"
        case "petroleum-gas": return "petroleum-gas"
        case "lubricant": return "lubricant"
        case "sulfuric-acid": return "sulfuric-acid"
        case "steam": return "steam"
        
        // Other items
        case "wood": return "wood"
        case "pipe": return "pipe"
        case "concrete": return "concrete"
        case "stone-brick": return "stone-brick"
        case "rail": return "rail"
        case "solid-fuel": return "solid-fuel"
        
        // If no specific mapping found, return the normalized name
        // This allows the system to try finding an icon with that exact name
        default:
            // Also try without hyphens as a fallback
            return normalizedItem
        }
    }
    
    private func drawEdges(in context: CGContext) {
        guard let graphState = graphState else { return }
        
        let scale = graphState.canvasScale
        let offset = NSSize(
            width: graphState.canvasOffset.width + tempPanOffset.width,
            height: graphState.canvasOffset.height + tempPanOffset.height
        )
        
        for edge in graphState.edges {
            guard let fromNode = graphState.nodes[edge.fromNode],
                  let toNode = graphState.nodes[edge.toNode] else { continue }
            
            drawEdge(from: fromNode, to: toNode, item: edge.item,
                    scale: scale, offset: offset, in: context)
        }
    }
    
    private func drawEdge(from fromNode: Node, to toNode: Node, item: String,
                         scale: CGFloat, offset: NSSize, in context: CGContext) {
        // Calculate port positions
        let fromX = fromNode.x * scale + offset.width + Constants.nodeMinWidth * scale / 2
        let fromY = fromNode.y * scale + offset.height
        let toX = toNode.x * scale + offset.width - Constants.nodeMinWidth * scale / 2
        let toY = toNode.y * scale + offset.height
        
        // Draw bezier curve
        let path = NSBezierPath()
        path.move(to: NSPoint(x: fromX, y: fromY))
        
        let controlOffset = abs(toX - fromX) * 0.5
        path.curve(to: NSPoint(x: toX, y: toY),
                  controlPoint1: NSPoint(x: fromX + controlOffset, y: fromY),
                  controlPoint2: NSPoint(x: toX - controlOffset, y: toY))
        
        context.setStrokeColor(NSColor.orange.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(Constants.wireLineWidth)
        context.addPath(path.cgPath)
        context.strokePath()
    }
    
    private func drawDragWire(from: NSPoint, to: NSPoint, in context: CGContext) {
        let path = NSBezierPath()
        path.move(to: from)
        
        let controlOffset = abs(to.x - from.x) * 0.5
        path.curve(to: to,
                  controlPoint1: NSPoint(x: from.x + controlOffset, y: from.y),
                  controlPoint2: NSPoint(x: to.x - controlOffset, y: to.y))
        
        context.setStrokeColor(NSColor.blue.withAlphaComponent(0.8).cgColor)
        context.setLineWidth(Constants.wireLineWidth)
        context.setLineDash(phase: 0, lengths: [5, 5])
        context.addPath(path.cgPath)
        context.strokePath()
    }
    
    private func drawSelectionBox(in context: CGContext) {
        let rect = CGRect(
            x: min(selectionStart.x, selectionEnd.x),
            y: min(selectionStart.y, selectionEnd.y),
            width: abs(selectionEnd.x - selectionStart.x),
            height: abs(selectionEnd.y - selectionStart.y)
        )
        
        context.setFillColor(NSColor.blue.withAlphaComponent(0.1).cgColor)
        context.fill(rect)
        
        context.setStrokeColor(NSColor.blue.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1)
        context.stroke(rect)
    }
    
    // MARK: - Mouse Events
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        lastMousePosition = point
        graphState?.lastMousePosition = CGPoint(x: point.x, y: point.y)
        
        // Check for space bar (panning)
        if event.modifierFlags.contains(.function) {
            isPanning = true
            panStart = point
            return
        }
        
        // Check if we hit a port
        if let (node, port, portItem) = portAt(point: point) {
            isDraggingWire = true
            wireStart = (nodeID: node.id, portID: port, point: point)
            wireEnd = point
            return
        }
        
        // Check if we hit a node
        if let node = nodeAt(point: point) {
            if event.modifierFlags.contains(.shift) {
                // Multi-select
                if graphState?.selectedNodeIDs.contains(node.id) == true {
                    graphState?.selectedNodeIDs.remove(node.id)
                } else {
                    graphState?.selectedNodeIDs.insert(node.id)
                }
            } else {
                graphState?.selectNode(node.id)
            }
            
            isDraggingNode = true
            draggedNodeID = node.id
            dragOffset = NSPoint(
                x: point.x - (node.x * (graphState?.canvasScale ?? 1) +
                            (graphState?.canvasOffset.width ?? 0)),
                y: point.y - (node.y * (graphState?.canvasScale ?? 1) +
                            (graphState?.canvasOffset.height ?? 0))
            )
        } else {
            // Start box selection
            graphState?.deselectAll()
            isBoxSelecting = true
            selectionStart = point
            selectionEnd = point
        }
        
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        lastMousePosition = point
        
        if isPanning {
            let dx = point.x - panStart.x
            let dy = point.y - panStart.y
            tempPanOffset = NSSize(width: dx, height: dy)
        } else if isDraggingNode, let nodeID = draggedNodeID {
            // Move selected node(s)
            let scale = graphState?.canvasScale ?? 1
            let offset = graphState?.canvasOffset ?? .zero
            
            let newX = (point.x - dragOffset.x - offset.width) / scale
            let newY = (point.y - dragOffset.y - offset.height) / scale
            
            if var node = graphState?.nodes[nodeID] {
                node.x = newX
                node.y = newY
                graphState?.updateNode(node)
            }
        } else if isDraggingWire {
            wireEnd = point
        } else if isBoxSelecting {
            selectionEnd = point
        }
        
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        if isPanning {
            graphState?.canvasOffset.width += tempPanOffset.width
            graphState?.canvasOffset.height += tempPanOffset.height
            tempPanOffset = .zero
            isPanning = false
        } else if isDraggingWire {
            // Check if we ended on a port
            if let start = wireStart,
               let (endNode, _, endItem) = portAt(point: point) {
                // Create edge
                graphState?.addEdge(from: start.nodeID, to: endNode.id,
                                  item: endItem, quality: .normal)
            }
            isDraggingWire = false
            wireStart = nil
        } else if isBoxSelecting {
            // Select nodes in box
            selectNodesInBox()
            isBoxSelecting = false
        }
        
        isDraggingNode = false
        draggedNodeID = nil
        needsDisplay = true
    }
    
    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        lastMousePosition = point
        graphState?.lastMousePosition = CGPoint(x: point.x, y: point.y)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        // Check if we right-clicked on a node
        if let node = nodeAt(point: point) {
            showNodeContextMenu(for: node, at: event)
        } else {
            showCanvasContextMenu(at: event, point: point)
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard !event.modifierFlags.contains(.option) else {
            super.scrollWheel(with: event)
            return
        }
        
        // Zoom with scroll wheel
        let zoomDelta = event.scrollingDeltaY * 0.01
        let newScale = max(0.3, min(3.0, (graphState?.canvasScale ?? 1) + zoomDelta))
        
        // Zoom toward mouse position
        let mouseInCanvas = lastMousePosition
        graphState?.zoomToward(scale: newScale, toward: mouseInCanvas)
    }
    
    // MARK: - Hit Testing
    private func nodeAt(point: NSPoint) -> Node? {
        guard let graphState = graphState else { return nil }
        
        let scale = graphState.canvasScale
        let offset = graphState.canvasOffset
        
        for node in graphState.nodes.values {
            let nodeX = node.x * scale + offset.width
            let nodeY = node.y * scale + offset.height
            let nodeWidth = Constants.nodeMinWidth * scale
            let nodeHeight = Constants.nodeHeight * scale
            
            let nodeRect = NSRect(
                x: nodeX - nodeWidth/2,
                y: nodeY - nodeHeight/2,
                width: nodeWidth,
                height: nodeHeight
            )
            
            if nodeRect.contains(point) {
                return node
            }
        }
        
        return nil
    }
    
    private func portAt(point: NSPoint) -> (node: Node, portID: UUID, item: String)? {
        guard let graphState = graphState else { return nil }
        
        let scale = graphState.canvasScale
        let offset = graphState.canvasOffset
        
        for node in graphState.nodes.values {
            guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else { continue }
            
            let nodeX = node.x * scale + offset.width
            let nodeY = node.y * scale + offset.height
            let nodeWidth = Constants.nodeMinWidth * scale
            
            // Port dimensions
            let portWidth: CGFloat = 60 * scale
            let portHeight: CGFloat = 24 * scale
            let portSpacing: CGFloat = 8 * scale
            
            // Calculate port positions for inputs
            let maxInputs = recipe.inputs.count
            if maxInputs > 0 {
                let totalInputHeight = CGFloat(maxInputs) * portHeight + CGFloat(maxInputs - 1) * portSpacing
                let inputStartY = totalInputHeight / 2
                
                for (index, (itemName, _)) in recipe.inputs.enumerated() {
                    let yOffset = inputStartY - CGFloat(index) * (portHeight + portSpacing)
                    let portRect = NSRect(
                        x: nodeX - nodeWidth/2 + 5 * scale,
                        y: nodeY + yOffset - portHeight/2,
                        width: portWidth,
                        height: portHeight
                    )
                    
                    if portRect.contains(point) {
                        return (node, UUID(), itemName)
                    }
                }
            }
            
            // Calculate port positions for outputs
            let maxOutputs = recipe.outputs.count
            if maxOutputs > 0 {
                let totalOutputHeight = CGFloat(maxOutputs) * portHeight + CGFloat(maxOutputs - 1) * portSpacing
                let outputStartY = totalOutputHeight / 2
                
                for (index, (itemName, _)) in recipe.outputs.enumerated() {
                    let yOffset = outputStartY - CGFloat(index) * (portHeight + portSpacing)
                    let portRect = NSRect(
                        x: nodeX + nodeWidth/2 - portWidth - 5 * scale,
                        y: nodeY + yOffset - portHeight/2,
                        width: portWidth,
                        height: portHeight
                    )
                    
                    if portRect.contains(point) {
                        return (node, UUID(), itemName)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func selectNodesInBox() {
        guard let graphState = graphState else { return }
        
        let scale = graphState.canvasScale
        let offset = graphState.canvasOffset
        
        let selectionRect = NSRect(
            x: min(selectionStart.x, selectionEnd.x),
            y: min(selectionStart.y, selectionEnd.y),
            width: abs(selectionEnd.x - selectionStart.x),
            height: abs(selectionEnd.y - selectionStart.y)
        )
        
        graphState.selectedNodeIDs.removeAll()
        
        for node in graphState.nodes.values {
            let nodeX = node.x * scale + offset.width
            let nodeY = node.y * scale + offset.height
            let nodeWidth = Constants.nodeMinWidth * scale
            let nodeHeight = Constants.nodeHeight * scale
            
            let nodeRect = NSRect(
                x: nodeX - nodeWidth/2,
                y: nodeY - nodeHeight/2,
                width: nodeWidth,
                height: nodeHeight
            )
            
            if selectionRect.intersects(nodeRect) {
                graphState.selectedNodeIDs.insert(node.id)
            }
        }
    }
    
    // MARK: - Context Menus
    private func showNodeContextMenu(for node: Node, at event: NSEvent) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Set Production Target...",
                    action: #selector(setProductionTarget(_:)),
                    keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Copy", action: #selector(copyNode(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Cut", action: #selector(cutNode(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Delete", action: #selector(deleteNode(_:)), keyEquivalent: "")
        
        menu.items.forEach { $0.representedObject = node.id }
        
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    private func showCanvasContextMenu(at event: NSEvent, point: NSPoint) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Add Recipe...",
                    action: #selector(addRecipe(_:)),
                    keyEquivalent: "")
        
        if graphState?.clipboard != nil {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Paste", action: #selector(pasteNode(_:)), keyEquivalent: "")
        }
        
        menu.items.forEach { $0.representedObject = point }
        
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    @objc private func setProductionTarget(_ sender: NSMenuItem) {
        guard let nodeID = sender.representedObject as? UUID else { return }
        
        // Show input dialog
        let alert = NSAlert()
        alert.messageText = "Set Production Target"
        alert.informativeText = "Enter items per minute:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        if let currentTarget = graphState?.nodes[nodeID]?.targetPerMin {
            inputField.stringValue = String(format: "%.1f", currentTarget)
        }
        alert.accessoryView = inputField
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let value = Double(inputField.stringValue) {
                graphState?.setTarget(for: nodeID, to: value)
            }
        }
    }
    
    @objc private func copyNode(_ sender: NSMenuItem) {
        guard let nodeID = sender.representedObject as? UUID else { return }
        graphState?.selectedNodeID = nodeID
        graphState?.copyNode()
    }
    
    @objc private func cutNode(_ sender: NSMenuItem) {
        guard let nodeID = sender.representedObject as? UUID else { return }
        graphState?.selectedNodeID = nodeID
        graphState?.cutNode()
    }
    
    @objc private func deleteNode(_ sender: NSMenuItem) {
        guard let nodeID = sender.representedObject as? UUID else { return }
        graphState?.removeNode(nodeID)
    }
    
    @objc private func addRecipe(_ sender: NSMenuItem) {
        guard let point = sender.representedObject as? NSPoint else { return }
        
        // Convert screen point to canvas coordinates
        let scale = graphState?.canvasScale ?? 1
        let offset = graphState?.canvasOffset ?? .zero
        let canvasPoint = CGPoint(
            x: (point.x - offset.width) / scale,
            y: (point.y - offset.height) / scale
        )
        
        graphState?.generalPickerDropPoint = canvasPoint
        
        // Show recipe picker
        if let window = window {
            let pickerWindow = GeneralRecipePickerWindow(graphState: graphState!)
            window.beginSheet(pickerWindow)
        }
    }
    
    @objc private func pasteNode(_ sender: NSMenuItem) {
        guard let point = sender.representedObject as? NSPoint else { return }
        
        // Convert screen point to canvas coordinates
        let scale = graphState?.canvasScale ?? 1
        let offset = graphState?.canvasOffset ?? .zero
        
        graphState?.lastMousePosition = CGPoint(
            x: (point.x - offset.width) / scale,
            y: (point.y - offset.height) / scale
        )
        
        graphState?.pasteNode()
    }
}

// MARK: - NSBezierPath Extension
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo, .cubicCurveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            case .quadraticCurveTo:
                let current = path.currentPoint
                let c1 = CGPoint(x: (current.x + 2 * points[0].x) / 3,
                               y: (current.y + 2 * points[0].y) / 3)
                let c2 = CGPoint(x: (2 * points[0].x + points[1].x) / 3,
                               y: (2 * points[0].y + points[1].y) / 3)
                path.addCurve(to: points[1], control1: c1, control2: c2)
            @unknown default:
                break
            }
        }
        
        return path
    }
}
