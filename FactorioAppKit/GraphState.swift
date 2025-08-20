import Foundation
import Cocoa
import Combine


// MARK: - Graph State
final class GraphState: ObservableObject, Codable {
    enum CodingKeys: CodingKey {
        case nodes, edges, userSetTargets
    }
    
    enum Aggregate: String, CaseIterable {
        case max = "Max"
        case sum = "Sum"
    }
    
    @Published var nodes: [UUID: Node] = [:] {
        didSet { autoSave() }
    }
    @Published var edges: [Edge] = [] {
        didSet { autoSave() }
    }
    @Published var dragging: DragContext? = nil
    @Published var showPicker = false
    @Published var pickerContext: PickerContext? = nil
    @Published var showGeneralPicker = false
    @Published var generalPickerDropPoint: CGPoint = .zero
    @Published var aggregate: Aggregate = .max {
        didSet { savePreferences() }
    }
    @Published var portFrames: [PortKey: CGRect] = [:]
    @Published var lastMousePosition: CGPoint = CGPoint(x: 400, y: 300)
    
    // Selection and clipboard
    @Published var selectedNodeID: UUID? = nil
    @Published var clipboard: Node? = nil
    @Published var clipboardWasCut: Bool = false
    @Published var copiedModule: Module? = nil
    
    // Multi-selection and canvas controls
    @Published var selectedNodeIDs: Set<UUID> = []
    @Published var canvasScale: Double = 1.0
    @Published var canvasOffset: CGSize = .zero
    @Published var isSelecting = false
    @Published var selectionStart: CGPoint = .zero
    @Published var selectionEnd: CGPoint = .zero
    
    // Track user-set targets
    @Published var userSetTargets: [UUID: Double] = [:]
    
    private var saveTimer: Timer?
    private var isComputing = false
    private var pendingCompute = false
    
    init() {
        loadAutoSave()
        loadPreferences()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nodeArray = try container.decode([Node].self, forKey: .nodes)
        self.nodes = Dictionary(uniqueKeysWithValues: nodeArray.map { ($0.id, $0) })
        self.edges = try container.decode([Edge].self, forKey: .edges)
        self.userSetTargets = try container.decodeIfPresent([UUID: Double].self, forKey: .userSetTargets) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(nodes.values), forKey: .nodes)
        try container.encode(edges, forKey: .edges)
        try container.encode(userSetTargets, forKey: .userSetTargets)
    }
    
    // MARK: - Selection
    func selectNode(_ nodeID: UUID) {
        selectedNodeID = nodeID
        selectedNodeIDs = [nodeID]
    }
    
    func deselectAll() {
        selectedNodeID = nil
        selectedNodeIDs.removeAll()
    }
    
    // MARK: - Clipboard Operations
    func copyNode() {
        guard let nodeID = selectedNodeID,
              let node = nodes[nodeID] else { return }
        clipboard = node
        clipboardWasCut = false
    }
    
    func cutNode() {
        guard let nodeID = selectedNodeID,
              let node = nodes[nodeID] else { return }
        clipboard = node
        clipboardWasCut = true
        removeNode(nodeID)
    }
    
    func pasteNode() {
        guard var node = clipboard else { return }
        
        // Update position to mouse location
        node.id = UUID()
        node.x = lastMousePosition.x
        node.y = lastMousePosition.y
        
        nodes[node.id] = node
        selectNode(node.id)
        
        if clipboardWasCut {
            clipboard = nil
            clipboardWasCut = false
        }
        
        computeFlows()
    }
    
    func deleteSelectedNode() {
        if let nodeID = selectedNodeID {
            removeNode(nodeID)
            selectedNodeID = nil
        }
    }
    
    func deleteSelectedNodes() {
        for nodeID in selectedNodeIDs {
            removeNode(nodeID)
        }
        selectedNodeIDs = []
        selectedNodeID = nil
    }
    
    func canPaste() -> Bool {
        return clipboard != nil
    }
    
    // MARK: - Graph Management
    func clearGraph() {
        nodes.removeAll()
        edges.removeAll()
        selectedNodeID = nil
        selectedNodeIDs = []
        userSetTargets.removeAll()
        computeFlows()
    }
    
    @discardableResult
    func addNode(recipeID: String, at point: CGPoint) -> Node {
        var node = Node(recipeID: recipeID, x: point.x, y: point.y)
        
        if let recipe = RECIPES.first(where: { $0.id == recipeID }),
           let tiers = MACHINE_TIERS[recipe.category] {
            let preferences = MachinePreferences.load()
            if let defaultTierID = preferences.getDefaultTier(for: recipe.category),
               tiers.contains(where: { $0.id == defaultTierID }) {
                node.selectedMachineTierID = defaultTierID
            }
            
            if let selectedTier = getSelectedMachineTier(for: node) {
                node.modules = Array(repeating: nil, count: selectedTier.moduleSlots)
            }
        }
        
        nodes[node.id] = node
        selectedNodeID = node.id
        
        return node
    }
    
    func updateNode(_ node: Node) {
        nodes[node.id] = node
        computeFlows()
    }
    
    func setTarget(for nodeID: UUID, to value: Double?) {
        guard var node = nodes[nodeID] else { return }
        
        node.targetPerMin = value.map { max(0, $0) }
        nodes[nodeID] = node
        
        if let value = value, value > 0 {
            // Clear other user-set targets in the same network
            let network = findConnectedNodes(from: nodeID)
            for id in network {
                if id != nodeID {
                    userSetTargets.removeValue(forKey: id)
                }
            }
            // Set this as the new user target
            userSetTargets[nodeID] = value
        } else {
            userSetTargets.removeValue(forKey: nodeID)
        }
        
        computeFlows()
    }
    
    func addEdge(from: UUID, to: UUID, item: String, quality: Quality = .normal) {
        guard from != to else { return }
        
        let edgeExists = edges.contains { edge in
            edge.fromNode == from && edge.toNode == to &&
            edge.item == item && edge.quality == quality
        }
        
        if !edgeExists {
            edges.append(Edge(fromNode: from, toNode: to,
                            item: item, quality: quality))
            computeFlows()
        }
    }
    
    func removeEdge(_ edge: Edge) {
        edges.removeAll { $0.id == edge.id }
        computeFlows()
    }
    
    func removeNode(_ nodeID: UUID) {
        nodes.removeValue(forKey: nodeID)
        edges.removeAll { $0.fromNode == nodeID || $0.toNode == nodeID }
        userSetTargets.removeValue(forKey: nodeID)
        computeFlows()
    }
    
    // MARK: - Flow Computation
    func computeFlows() {
        guard !isComputing else {
            pendingCompute = true
            return
        }
        
        isComputing = true
        defer {
            isComputing = false
            if pendingCompute {
                pendingCompute = false
                DispatchQueue.main.async { [weak self] in
                    self?.computeFlows()
                }
            }
        }
        
        // If we have user-set targets, propagate from those
        if !userSetTargets.isEmpty {
            propagateNetworkFlows()
        } else {
            standardFlowComputation()
        }
    }
    
    func triggerFlowComputation() {
        computeFlows()
    }
    
    private func propagateNetworkFlows() {
        var targets: [UUID: Double] = [:]
        
        // Find all connected networks
        let networks = findAllNetworks()
        
        // For each network, propagate from user-set nodes
        for network in networks {
            // Find user-set nodes in this network
            let userSetInNetwork = network.filter { userSetTargets.keys.contains($0) }
            
            if !userSetInNetwork.isEmpty {
                // Use the first user-set node as source
                if let sourceNodeID = userSetInNetwork.first,
                   let sourceTarget = userSetTargets[sourceNodeID] {
                    
                    // Propagate through the network
                    propagateThroughNetwork(
                        network: network,
                        sourceNodeID: sourceNodeID,
                        sourceTarget: sourceTarget,
                        targets: &targets
                    )
                }
            }
        }
        
        // Update all nodes with computed values
        for (nodeID, var node) in nodes {
            let newTarget = targets[nodeID]
            let roundedTarget: Double? = if let target = newTarget, target > Constants.computationTolerance {
                abs(target - round(target)) < 0.01 ? round(target) : target
            } else {
                nil
            }
            
            if node.targetPerMin != roundedTarget {
                node.targetPerMin = roundedTarget
                nodes[nodeID] = node
            }
        }
    }
    
    private func standardFlowComputation() {
        // Clear all targets
        for (nodeID, var node) in nodes {
            if node.targetPerMin != nil {
                node.targetPerMin = nil
                nodes[nodeID] = node
            }
        }
    }
    
    private func propagateThroughNetwork(network: Set<UUID>, sourceNodeID: UUID,
                                        sourceTarget: Double, targets: inout [UUID: Double]) {
        targets[sourceNodeID] = sourceTarget
        
        var toProcess = [(nodeID: sourceNodeID, target: sourceTarget)]
        var processed = Set<UUID>()
        
        while !toProcess.isEmpty {
            let (currentNodeID, currentTarget) = toProcess.removeFirst()
            
            if processed.contains(currentNodeID) { continue }
            processed.insert(currentNodeID)
            
            guard let currentNode = nodes[currentNodeID],
                  let recipe = RECIPES.first(where: { $0.id == currentNode.recipeID }) else {
                continue
            }
            
            // Calculate rates with productivity
            let primaryOutput = recipe.outputs.first?.value ?? 1
            let actualPrimaryOutput = primaryOutput * (1 + currentNode.totalProductivityBonus)
            let craftsPerSec = currentTarget / actualPrimaryOutput
            
            // Process inputs
            for (item, amount) in recipe.inputs {
                let requiredRate = craftsPerSec * amount
                
                // Find suppliers
                let suppliers = edges.filter { edge in
                    edge.toNode == currentNodeID && edge.item == item
                }
                
                for supplier in suppliers {
                    if let supplierNode = nodes[supplier.fromNode],
                       let supplierRecipe = RECIPES.first(where: { $0.id == supplierNode.recipeID }),
                       let outputAmount = supplierRecipe.outputs[item] {
                        
                        let actualOutput = outputAmount * (1 + supplierNode.totalProductivityBonus)
                        let supplierTarget = (requiredRate / actualOutput) *
                                           (supplierRecipe.outputs.first?.value ?? 1) *
                                           (1 + supplierNode.totalProductivityBonus)
                        
                        if let existingTarget = targets[supplier.fromNode] {
                            targets[supplier.fromNode] = aggregate == .max ?
                                max(existingTarget, supplierTarget) : existingTarget + supplierTarget
                        } else {
                            targets[supplier.fromNode] = supplierTarget
                            toProcess.append((nodeID: supplier.fromNode, target: supplierTarget))
                        }
                    }
                }
            }
            
            // Process outputs
            for (item, amount) in recipe.outputs {
                let actualAmount = amount * (1 + currentNode.totalProductivityBonus)
                let outputRate = craftsPerSec * actualAmount
                
                // Find consumers
                let consumers = edges.filter { edge in
                    edge.fromNode == currentNodeID && edge.item == item
                }
                
                for consumer in consumers {
                    if let consumerNode = nodes[consumer.toNode],
                       let consumerRecipe = RECIPES.first(where: { $0.id == consumerNode.recipeID }),
                       let inputAmount = consumerRecipe.inputs[item] {
                        
                        let consumerCraftsPerSec = outputRate / inputAmount
                        let consumerTarget = consumerCraftsPerSec *
                                           (consumerRecipe.outputs.first?.value ?? 1) *
                                           (1 + consumerNode.totalProductivityBonus)
                        
                        if let existingTarget = targets[consumer.toNode] {
                            targets[consumer.toNode] = aggregate == .max ?
                                max(existingTarget, consumerTarget) : existingTarget + consumerTarget
                        } else {
                            targets[consumer.toNode] = consumerTarget
                            toProcess.append((nodeID: consumer.toNode, target: consumerTarget))
                        }
                    }
                }
            }
        }
    }
    
    private func findConnectedNodes(from nodeID: UUID) -> Set<UUID> {
        var connected = Set<UUID>([nodeID])
        var toExplore = [nodeID]
        
        while !toExplore.isEmpty {
            let current = toExplore.removeFirst()
            
            for edge in edges {
                if edge.fromNode == current && !connected.contains(edge.toNode) {
                    connected.insert(edge.toNode)
                    toExplore.append(edge.toNode)
                } else if edge.toNode == current && !connected.contains(edge.fromNode) {
                    connected.insert(edge.fromNode)
                    toExplore.append(edge.fromNode)
                }
            }
        }
        
        return connected
    }
    
    private func findAllNetworks() -> [Set<UUID>] {
        var networks: [Set<UUID>] = []
        var visited = Set<UUID>()
        
        for nodeID in nodes.keys {
            if !visited.contains(nodeID) {
                let network = findConnectedNodes(from: nodeID)
                networks.append(network)
                visited.formUnion(network)
            }
        }
        
        return networks
    }
    
    // MARK: - Canvas Controls
    func zoomIn() {
        canvasScale = min(3.0, canvasScale * 1.1)
    }
    
    func zoomOut() {
        canvasScale = max(0.3, canvasScale * 0.9)
    }
    
    func resetZoom() {
        canvasScale = 1.0
        canvasOffset = .zero
    }
    
    func zoomToward(scale: Double, toward point: CGPoint) {
        let oldScale = canvasScale
        canvasScale = scale
        
        // Adjust offset to zoom toward point
        let scaleRatio = scale / oldScale
        canvasOffset.width = point.x - (point.x - canvasOffset.width) * scaleRatio
        canvasOffset.height = point.y - (point.y - canvasOffset.height) * scaleRatio
    }
    
    // MARK: - Import/Export
    func exportJSON(from window: NSWindow?) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "factorio_plan.json"
        
        guard let targetWindow = window ?? NSApp.keyWindow else { return }
        
        savePanel.beginSheetModal(for: targetWindow) { response in
            guard response == .OK, let url = savePanel.url else { return }
            
            do {
                let data = try JSONEncoder().encode(self)
                try data.write(to: url)
            } catch {
                DispatchQueue.main.async {
                    NSAlert(error: error).runModal()
                }
            }
        }
    }
    
    func importJSON(from window: NSWindow?) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        
        guard let targetWindow = window ?? NSApp.keyWindow else { return }
        
        openPanel.beginSheetModal(for: targetWindow) { response in
            guard response == .OK, let url = openPanel.url else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let graphState = try JSONDecoder().decode(GraphState.self, from: data)
                
                DispatchQueue.main.async {
                    self.nodes = graphState.nodes
                    self.edges = graphState.edges
                    self.userSetTargets = graphState.userSetTargets
                    self.selectedNodeID = nil
                    self.selectedNodeIDs = []
                    self.computeFlows()
                }
            } catch {
                DispatchQueue.main.async {
                    NSAlert(error: error).runModal()
                }
            }
        }
    }
    
    // MARK: - Auto-Save
    private func autoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.performSave()
        }
    }
    
    private func performSave() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: "FactorioPlannerAutoSave")
        } catch {
            print("Failed to auto-save: \(error)")
        }
    }
    
    func loadAutoSave() {
        guard let data = UserDefaults.standard.data(forKey: "FactorioPlannerAutoSave") else {
            return
        }
        
        do {
            let savedState = try JSONDecoder().decode(GraphState.self, from: data)
            self.nodes = savedState.nodes
            self.edges = savedState.edges
            self.userSetTargets = savedState.userSetTargets
            
            DispatchQueue.main.async {
                self.computeFlows()
            }
        } catch {
            print("Failed to load auto-save: \(error)")
        }
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(aggregate.rawValue, forKey: "FactorioPlannerAggregate")
    }
    
    private func loadPreferences() {
        if let aggregateRaw = UserDefaults.standard.string(forKey: "FactorioPlannerAggregate"),
           let loadedAggregate = Aggregate(rawValue: aggregateRaw) {
            self.aggregate = loadedAggregate
        }
    }
}
