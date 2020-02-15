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
    @IBOutlet private weak var testLabel: UILabel!
    
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
    
    init(viewModel: CharactersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: CharactersListViewController.self), bundle: nil)
        self.viewModel.setViewModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListViewModelConsumer protocol
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.testLabel.text = NSLocalizedString("CharactersListViewController.testLabel.text", comment: AppConstants.LocalizedStringComment.labelTitle)
    }
}
