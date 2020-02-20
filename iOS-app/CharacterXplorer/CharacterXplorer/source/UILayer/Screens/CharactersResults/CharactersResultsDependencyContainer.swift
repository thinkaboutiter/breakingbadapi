//
//  CharactersResultsDependencyContainer.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-20-Feb-Thu.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol CharactersResultsDependencyContainer: AnyObject {}

class CharactersResultsDependencyContainerImpl: CharactersResultsDependencyContainer, CharactersResultsViewControllerFactory {
    
    // MARK: - Properties
    private let parent: CharactersListDependencyContainer
    
    // MARK: - Initialization
    init(parent: CharactersListDependencyContainer) {
        // setup
        self.parent = parent
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersResultsViewControllerFactory protocol
    func makeCharactersResultsViewController() -> CharactersResultsViewController {
        let vm: CharactersResultsViewModel = self.makeCharactersResultsViewModel()
        let vc: CharactersResultsViewController = CharactersResultsViewController(viewModel: vm)
        return vc
    }
    
    private func makeCharactersResultsViewModel() -> CharactersResultsViewModel {
        let model: CharactersResultsModel = CharactersResultsModelImpl()
        let result: CharactersResultsViewModel = CharactersResultsViewModelImpl(model: model)
        return result
    }
}
