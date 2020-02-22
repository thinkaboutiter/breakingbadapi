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
    private let provideCharacterDetailsViewControllerFactoryWith: CharacterDetailsViewControllerFactoryProvider
    private let imageCache: ImageCacheManager
    private let contextNavigationController: UINavigationController
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
    
    /// Custom initializer.
    /// - Parameters:
    ///   - viewModel: the view model object
    ///   - provider: closure to provide `CharacterDerailsViewController` object
    ///   - imageCache: shared image cache
    ///   - contextNavigationController: `UINavigationController` object to be used to push new content onto
    init(viewModel: CharactersResultsViewModel,
         characterDetailsProvider provider: @escaping CharacterDetailsViewControllerFactoryProvider,
         imageCache: ImageCacheManager,
         contextNavigationController: BaseNavigationController)
    {
        self.viewModel = viewModel
        self.provideCharacterDetailsViewControllerFactoryWith = provider
        self.imageCache = imageCache
        self.contextNavigationController = contextNavigationController
        super.init(nibName: String(describing: CharactersResultsViewController.self), bundle: nil)
        self.viewModel.setViewModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersResultsViewModelConsumer protocol
    func reloadCharacters() {
        self.charactersTableView.reloadData()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure_ui()
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
        defer {
            tableView.deselectRow(at: indexPath,
                                  animated: true)
        }
        do {
            let character: BreakingBadCharacter = try self.viewModel.character(for: indexPath)
            let factory: CharacterDetailsViewControllerFactory =
                self.provideCharacterDetailsViewControllerFactoryWith(character)
            let vc: CharacterDetailsViewController = factory.makeCharacterDetailsViewController()
            self.contextNavigationController.pushViewController(vc,
                                                                animated: true)
        }
        catch {
            Logger.error.message().object(error as NSError)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
}

extension CharactersResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let valid_text: String = searchController.searchBar.text else {
            let message: String = NSLocalizedString("Invalid searchBar.text object!",
                                                    comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: InternalError.domainName,
                        code: InternalError.Code.invalidSearchText,
                        localizedMessage: message)
                .error()
            Logger.error.message().object(error)
            return
        }
        Logger.debug.message("searchBar.text=\(valid_text)")
        self.viewModel.getCharacterByName(valid_text)
    }
}

extension CharactersResultsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        guard let valid_season: BreakingBadSeason = BreakingBadSeason(rawValue: selectedScope) else {
            let message: String = NSLocalizedString("Unable to create \(String(describing: BreakingBadSeason.self)) value from raw_value=\(selectedScope)!",
                                                    comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: InternalError.domainName,
                        code: InternalError.Code.unableToCreateBreakingBadSeason,
                        localizedMessage: message)
                .error()
            Logger.error.message().object(error)
            return
        }
        self.viewModel.setSelectedSeason(valid_season)
    }
}

// MARK: - Constants
private extension CharactersResultsViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 82.0
    }
}

// MARK: - Internal Errors
private extension CharactersResultsViewController {
    
    enum InternalError {
        static let domainName: String = "\(AppConstants.projectName).\(String(describing: CharactersResultsViewController.self)).\(String(describing: InternalError.self))"
        
        enum Code {
            static let invalidSearchText: Int = 9000
            static let unableToCreateBreakingBadSeason: Int = 9001
        }
    }
}
