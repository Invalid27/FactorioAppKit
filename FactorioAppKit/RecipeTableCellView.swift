import Cocoa

// MARK: - Recipe Table Cell View
class RecipeTableCellView: NSView {
    private let nameLabel = NSTextField()
    private let categoryLabel = NSTextField()
    private let ioLabel = NSTextField()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Name label
        nameLabel.isEditable = false
        nameLabel.isBordered = false
        nameLabel.backgroundColor = .clear
        nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        // Category label
        categoryLabel.isEditable = false
        categoryLabel.isBordered = false
        categoryLabel.backgroundColor = .clear
        categoryLabel.font = .systemFont(ofSize: 11)
        categoryLabel.textColor = .secondaryLabelColor
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryLabel)
        
        // I/O label
        ioLabel.isEditable = false
        ioLabel.isBordered = false
        ioLabel.backgroundColor = .clear
        ioLabel.font = .systemFont(ofSize: 10)
        ioLabel.textColor = .tertiaryLabelColor
        ioLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ioLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            ioLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            ioLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 2),
            ioLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with recipe: Recipe) {
        nameLabel.stringValue = recipe.name
        categoryLabel.stringValue = getSimplifiedCategory(recipe).capitalized
        
        // Format inputs/outputs
        let inputs = recipe.inputs.map { "\($0.key): \(formatNumber($0.value))" }.joined(separator: ", ")
        let outputs = recipe.outputs.map { "\($0.key): \(formatNumber($0.value))" }.joined(separator: ", ")
        
        if !inputs.isEmpty && !outputs.isEmpty {
            ioLabel.stringValue = "\(inputs) → \(outputs)"
        } else if !outputs.isEmpty {
            ioLabel.stringValue = "→ \(outputs)"
        } else {
            ioLabel.stringValue = ""
        }
    }
    
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}
