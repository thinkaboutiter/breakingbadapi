//
//  CharactersResultsDependencyContainer.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-20-Feb-Thu.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol CharactersResultsDependencyContainer: ImageCacheProvider {}

class CharactersResultsDependencyContainerImpl: CharactersResultsDependencyContainer, CharactersResultsViewControllerFactory {
    
    // MARK: - Properties
    private let parent: CharactersListDependencyContainer
    private lazy var provider: CharacterDetailsViewControllerFactoryProvider = { character in
        let factory: CharacterDetailsViewControllerFactory =
            CharacterDetailsDependencyContainerImpl(parent: self) { () -> BreakingBadCharacter in
                return character
        }
        return factory
    }
    
    // MARK: - Initialization
    init(parent: CharactersListDependencyContainer) {
        // setup
        self.parent = parent
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersResultsDependencyContainer
    var imageCache: ImageCacheManager {
        return self.parent.imageCache
    }
    
    // MARK: - CharactersResultsViewControllerFactory protocol
    func makeCharactersResultsViewController() -> CharactersResultsViewController {
        let vm: CharactersResultsViewModel = self.makeCharactersResultsViewModel()
        let vc: CharactersResultsViewController = CharactersResultsViewController(viewModel: vm,
                                                                                  characterDetailsProvider: self.provider,
                                                                                  imageCache: self.imageCache,
                                                                                  contextNavigationController: self.parent.rootNavigationController)
        return vc
    }
    
    private func makeCharactersResultsViewModel() -> CharactersResultsViewModel {
        let model: CharactersResultsModel = CharactersResultsModelImpl()
        let result: CharactersResultsViewModel = CharactersResultsViewModelImpl(model: model)
        return result
    }
}
