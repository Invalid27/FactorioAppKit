import Cocoa

// MARK: - General Recipe Picker Window
class GeneralRecipePickerWindow: NSWindow {
    weak var graphState: GraphState?
    private var pickerController: GeneralRecipePickerViewController!
    
    init(graphState: GraphState) {
        self.graphState = graphState
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )
        
        title = "Add Recipe"
        isReleasedWhenClosed = false
        
        pickerController = GeneralRecipePickerViewController(graphState: graphState)
        contentViewController = pickerController
    }
}
