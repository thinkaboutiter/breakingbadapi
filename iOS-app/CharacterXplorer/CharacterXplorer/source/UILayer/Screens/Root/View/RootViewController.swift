//
//  RootViewController.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

/// APIs for `DependecyContainer` to expose.
protocol RootViewControllerFactory {
    func makeRootViewController() -> RootViewController
}

class RootViewController: BaseViewController {
    
    // MARK: - Properties
    @IBOutlet weak var testLabel: UILabel!
    private let charactersListViewControllerFactory: CharactersListViewControllerFactory
    
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
    
    init(charactersListViewControllerFactory factory: CharactersListViewControllerFactory) {
        self.charactersListViewControllerFactory = factory
        super.init(nibName: String(describing: RootViewController.self), bundle: nil)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - RootViewModelConsumer protocol
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.embedCharactersListViewController()
    }
}

// MARK: - Embedding
private extension RootViewController {
    
    func embedCharactersListViewController() {
        let vc: CharactersListViewController = self.charactersListViewControllerFactory.makeCharactersListViewController()
        let nc: BaseNavigationController = BaseNavigationController(rootViewController: vc)
        do {
            try self.embed(nc,
                           containerView: self.view)
        }
        catch let error as NSError {
            Logger.error.message().object(error)
        }
    }
}
