//
//  CharactersListViewController.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

/// APIs for `DependecyContainer` to expose.
protocol CharactersListViewControllerFactory {
    func makeCharactersListViewController() -> CharactersListViewController
}

class CharactersListViewController: BaseViewController, CharactersListViewModelConsumer {
    
    // MARK: - Properties
    private let viewModel: CharactersListViewModel
    private let provideCharacterDetailsViewControllerFactoryWith: CharacterDetailsViewControllerFactoryProvider
    private let imageCache: ImageCacheManager
    @IBOutlet private weak var charactersTableView: CharactersTableView!
    
    // MARK: - Initialization
    @available(*, unavailable, message: "Creating this view controller with `init(coder:)` is unsupported in favor of initializer dependency injection.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("Creating this view controller with `init(coder:)` is unsupported in favor of dependency injection initializer.")
    }
    
    @available(*, unavailable, message: "Creating this view controller with `init(nibName:bundle:)` is unsupported in favor of initializer dependency injection.")
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?)
    {
        fatalError("Creating this view controller with `init(nibName:bundle:)` is unsupported in favor of dependency injection initializer.")
    }
    
    init(viewModel: CharactersListViewModel,
         provider: @escaping CharacterDetailsViewControllerFactoryProvider,
         imageCache: ImageCacheManager)
    {
        self.viewModel = viewModel
        self.provideCharacterDetailsViewControllerFactoryWith = provider
        self.imageCache = imageCache
        super.init(nibName: String(describing: CharactersListViewController.self), bundle: nil)
        self.viewModel.setViewModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListViewModelConsumer protocol
    func loadCharacters(via viewModel: CharactersListViewModel) {
        self.charactersTableView.reloadData()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure_ui()
        self.viewModel.fetchCharacters()
    }
}

// MARK: - UI configurations
private extension CharactersListViewController {
    
    func configure_ui() {
        self.configure_title(&self.title)
        self.configure_charactersTableView(self.charactersTableView)
    }
    
    func configure_title(_ title: inout String?) {
        title = NSLocalizedString("CharactersListViewController.title.samples",
                                  comment: AppConstants.LocalizedStringComment.screenTitle)
    }
    
    func configure_charactersTableView(_ tableView: CharactersTableView) {
        let identifier: String = "\(String(describing: CharacterTableViewCell.self))"
        tableView.register(UINib(nibName: identifier, bundle: nil),
                           forCellReuseIdentifier: identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.insetsContentViewsToSafeArea = true
    }
}

// MARK: - UITableViewDataSource protocol
extension CharactersListViewController: UITableViewDataSource {
    
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
extension CharactersListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath)
    {
        let count: Int = self.viewModel.getCharactes().count
        if indexPath.row == (count - 1) {
            self.viewModel.fetchCharacters()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        do {
            let character: BreakingBadCharacter = try self.viewModel.character(for: indexPath)
            let factory: CharacterDetailsViewControllerFactory =
                self.provideCharacterDetailsViewControllerFactoryWith(character)
            let vc: CharacterDetailsViewController = factory.makeCharacterDetailsViewController()
            self.navigationController?.pushViewController(vc,
                                                          animated: true)
        }
        catch {
            Logger.error.message().object(error as NSError)
        }
        tableView.deselectRow(at: indexPath,
                              animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
}

// MARK: - Constants
private extension CharactersListViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 82.0
    }
}
