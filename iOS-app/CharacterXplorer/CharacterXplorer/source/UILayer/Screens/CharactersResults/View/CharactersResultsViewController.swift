//
//  CharactersResultsViewController.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-20-Feb-Thu.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

/// APIs for `DependecyContainer` to expose.
protocol CharactersResultsViewControllerFactory {
    func makeCharactersResultsViewController() -> CharactersResultsViewController
}

class CharactersResultsViewController: BaseViewController, CharactersResultsViewModelConsumer {
    
    // MARK: - Properties
    private let viewModel: CharactersResultsViewModel
    private let imageCache: ImageCacheManager
    @IBOutlet private weak var charactersTableView: CharactersTableView!
    
    // MARK: - Initialization
    @available(*, unavailable, message: "Creating this view controller with `init(coder:)` is unsupported in favor of initializer dependency injection.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("Creating this view controller with `init(coder:)` is unsupported in favor of dependency injection initializer.")
    }
    
    @available(*, unavailable, message: "Creating this view controller with `init(nibName:bundle:)` is unsupported in favor of initializer dependency injection.")
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?) {
        fatalError("Creating this view controller with `init(nibName:bundle:)` is unsupported in favor of dependency injection initializer.")
    }
    
    init(viewModel: CharactersResultsViewModel,
         imageCache: ImageCacheManager)
    {
        self.viewModel = viewModel
        self.imageCache = imageCache
        super.init(nibName: String(describing: CharactersResultsViewController.self), bundle: nil)
        self.viewModel.setViewModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersResultsViewModelConsumer protocol
    func reloadCharacters(via viewModel: CharactersResultsViewModel) {
        self.charactersTableView.reloadData()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

// MARK: - UI configurations
private extension CharactersResultsViewController {
    
    func configure_ui() {
        self.configure_title(&self.title)
        self.configure_charactersTableView(self.charactersTableView)

    }
    
    func configure_title(_ title: inout String?) {
        title = NSLocalizedString("CharactersListViewController.title.characters",
                                  comment: AppConstants.LocalizedStringComment.screenTitle)
    }
    
    func configure_charactersTableView(_ tableView: CharactersTableView) {
        let identifier: String = "\(String(describing: CharacterTableViewCell.self))"
        tableView.register(UINib(nibName: identifier, bundle: nil),
                           forCellReuseIdentifier: identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.insetsContentViewsToSafeArea = true
        tableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDataSource protocol
extension CharactersResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        let result: Int = self.viewModel.getCharactes().count
        return result
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell: CharacterTableViewCell = tableView
            .dequeueReusableCell(withIdentifier: String(describing: CharacterTableViewCell.self),
                                 for: indexPath) as? CharacterTableViewCell
        else {
            let message: String = "Unable to dequeue valid \(String(describing: CharacterTableViewCell.self))!"
            Logger.error.message(message)
            assert(false, message)
        }
        
        do {
            let character: BreakingBadCharacter = try self.viewModel.character(for: indexPath)
            cell.configure(with: character, imageCache: self.imageCache)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        catch let error as NSError {
            Logger.error.message().object(error)
            assert(false, error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDelegate protocol
extension CharactersResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath,
                              animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
}

extension CharactersResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text: String? = searchController.searchBar.text
        Logger.debug.message("searchBar.text=\(text ?? "")")
    }
}

// MARK: - Constants
private extension CharactersResultsViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 82.0
    }
}
