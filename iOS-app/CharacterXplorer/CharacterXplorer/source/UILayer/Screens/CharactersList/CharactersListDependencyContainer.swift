//
//  CharactersListDependencyContainer.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol CharactersListDependencyContainer: AnyObject {}

class CharactersListDependencyContainerImpl: CharactersListDependencyContainer, CharactersListViewControllerFactory {
    
    // MARK: - Properties
    private let parent: RootDependencyContainer
    
    // MARK: - Initialization
    init(parent: RootDependencyContainer) {
        // setup
        self.parent = parent
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListViewControllerFactory protocol
    func makeCharactersListViewController() -> CharactersListViewController {
        let vm: CharactersListViewModel = self.makeCharactersListViewModel()
        let vc: CharactersListViewController = CharactersListViewController(viewModel: vm)
        return vc
    }
    
    private func makeCharactersListViewModel() -> CharactersListViewModel {
        let model: CharactersListModel = CharactersListModelImpl()
        let result: CharactersListViewModel = CharactersListViewModelImpl(model: model)
        return result
    }
}
