import Cocoa

// MARK: - Recipe Picker View Controller
class GeneralRecipePickerViewController: NSViewController {
    weak var graphState: GraphState?
    
    private var searchField: NSSearchField!
    private var categoryPopUp: NSPopUpButton!
    private var recyclingCheckbox: NSButton!
    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
    
    private var searchText = "" {
        didSet { filterRecipes() }
    }
    private var selectedCategory = "All" {
        didSet { filterRecipes() }
    }
    private var showRecycling = false {
        didSet { filterRecipes() }
    }
    
    private var allRecipes: [Recipe] = []
    private var filteredRecipes: [Recipe] = []
    private var categories: [String] = []
    
    init(graphState: GraphState) {
        self.graphState = graphState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 500))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadRecipes()
        filterRecipes()
    }
    
    private func setupUI() {
        // Search field
        searchField = NSSearchField()
        searchField.placeholderString = "Search recipes..."
        searchField.target = self
        searchField.action = #selector(searchFieldChanged(_:))
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        
        // Category selector
        categoryPopUp = NSPopUpButton()
        categoryPopUp.target = self
        categoryPopUp.action = #selector(categoryChanged(_:))
        categoryPopUp.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryPopUp)
        
        // Recycling checkbox
        recyclingCheckbox = NSButton(checkboxWithTitle: "Show Recycling",
                                    target: self,
                                    action: #selector(recyclingToggled(_:)))
        recyclingCheckbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recyclingCheckbox)
        
        // Table view in scroll view
        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = false
        view.addSubview(scrollView)
        
        tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleAction = #selector(tableDoubleClicked(_:))
        tableView.target = self
        tableView.allowsMultipleSelection = false
        tableView.headerView = nil
        tableView.rowHeight = 60
        
        // Add columns
        let iconColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("icon"))
        iconColumn.width = 40
        tableView.addTableColumn(iconColumn)
        
        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
        nameColumn.title = "Recipe"
        tableView.addTableColumn(nameColumn)
        
        scrollView.documentView = tableView
        
        // Buttons
        let cancelButton = NSButton(title: "Cancel", target: self,
                                   action: #selector(cancelClicked))
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        let addButton = NSButton(title: "Add", target: self,
                                action: #selector(addClicked))
        addButton.keyEquivalent = "\r"
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        // Layout
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchField.widthAnchor.constraint(equalToConstant: 200),
            
            categoryPopUp.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            categoryPopUp.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 10),
            categoryPopUp.widthAnchor.constraint(equalToConstant: 150),
            
            recyclingCheckbox.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            recyclingCheckbox.leadingAnchor.constraint(equalTo: categoryPopUp.trailingAnchor, constant: 10),
            
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -20),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            cancelButton.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10),
            
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Make search field first responder
        view.window?.makeFirstResponder(searchField)
    }
    
    private func loadRecipes() {
        allRecipes = RECIPES
        
        // Get unique categories
        let simplifiedCategories = Set(
            RECIPES
                .filter { !isRecyclingRecipe($0) }
                .map { getSimplifiedCategory($0) }
        )
        
        categories = ["All"] + simplifiedCategories.sorted()
        
        // Populate category popup
        categoryPopUp.removeAllItems()
        categoryPopUp.addItems(withTitles: categories)
    }
    
    private func filterRecipes() {
        filteredRecipes = allRecipes.filter { recipe in
            // Filter by recycling
            if !showRecycling && isRecyclingRecipe(recipe) {
                return false
            }
            if showRecycling && !isRecyclingRecipe(recipe) {
                return false
            }
            
            // Filter by category
            if selectedCategory != "All" {
                let simplified = getSimplifiedCategory(recipe)
                if simplified != selectedCategory {
                    return false
                }
            }
            
            // Filter by search text
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                return recipe.name.lowercased().contains(searchLower) ||
                       recipe.id.lowercased().contains(searchLower) ||
                       recipe.inputs.keys.contains { $0.lowercased().contains(searchLower) } ||
                       recipe.outputs.keys.contains { $0.lowercased().contains(searchLower) }
            }
            
            return true
        }
        
        tableView.reloadData()
        
        // Select first item
        if !filteredRecipes.isEmpty {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    @objc private func searchFieldChanged(_ sender: NSSearchField) {
        searchText = sender.stringValue
    }
    
    @objc private func categoryChanged(_ sender: NSPopUpButton) {
        selectedCategory = sender.selectedItem?.title ?? "All"
    }
    
    @objc private func recyclingToggled(_ sender: NSButton) {
        showRecycling = sender.state == .on
    }
    
    @objc private func cancelClicked() {
        view.window?.close()
    }
    
    @objc private func addClicked() {
        addSelectedRecipe()
    }
    
    @objc private func tableDoubleClicked(_ sender: Any) {
        addSelectedRecipe()
    }
    
    private func addSelectedRecipe() {
        guard tableView.selectedRow >= 0,
              tableView.selectedRow < filteredRecipes.count else { return }
        
        let recipe = filteredRecipes[tableView.selectedRow]
        
        // Add node at drop point
        let dropPoint = graphState?.generalPickerDropPoint ?? CGPoint(x: 400, y: 300)
        graphState?.addNode(recipeID: recipe.id, at: dropPoint)
        
        view.window?.close()
    }
}

// MARK: - Table View Data Source & Delegate
extension GeneralRecipePickerViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredRecipes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < filteredRecipes.count else { return nil }
        
        let recipe = filteredRecipes[row]
        
        if tableColumn?.identifier.rawValue == "icon" {
            // Icon cell
            let imageView = NSImageView()
            imageView.imageScaling = .scaleProportionallyDown
            
            let iconName = iconAssetName(for: recipe.mainOutput)
            if let icon = NSImage(named: iconName) {
                imageView.image = icon
            } else {
                // Create monogram
                let monogram = createMonogram(for: recipe.mainOutput)
                imageView.image = monogram
            }
            
            return imageView
        } else {
            // Name cell
            let cellView = RecipeTableCellView()
            cellView.configure(with: recipe)
            return cellView
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}
