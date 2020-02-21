//
//  CharactersListDependencyContainer.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol ImageCacheProvider: AnyObject {
    var imageCache: ImageCacheManager { get }
}

protocol CharactersListDependencyContainer: ImageCacheProvider {}

typealias CharacterDetailsViewControllerFactoryProvider = (BreakingBadCharacter) -> CharacterDetailsViewControllerFactory

class CharactersListDependencyContainerImpl: CharactersListDependencyContainer, CharactersListViewControllerFactory {
    
    // MARK: - Properties
    private let parent: RootDependencyContainer
    private lazy var provider: CharacterDetailsViewControllerFactoryProvider = { character in
        let factory: CharacterDetailsViewControllerFactory =
            CharacterDetailsDependencyContainerImpl(parent: self) { () -> BreakingBadCharacter in
                return character
        }
        return factory
    }
    private lazy var factory: CharactersResultsViewControllerFactory = {
        let result: CharactersResultsViewControllerFactory = CharactersResultsDependencyContainerImpl(parent: self)
        return result
    }()
    
    // MARK: - Initialization
    init(parent: RootDependencyContainer) {
        self.parent = parent
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListDependencyContainer
    var imageCache: ImageCacheManager {
        return self.parent.imageCache
    }
    
    // MARK: - CharactersListViewControllerFactory protocol
    func makeCharactersListViewController() -> CharactersListViewController {
        let vm: CharactersListViewModel = self.makeCharactersListViewModel()
        let vc: CharactersListViewController = CharactersListViewController(viewModel: vm,
                                                                            characterDetailsProvider: self.provider,
                                                                            charactersResultsFactory: self.factory,
                                                                            imageCache: self.imageCache)
        return vc
    }
    
    private func makeCharactersListViewModel() -> CharactersListViewModel {
        let model: CharactersListModel = CharactersListModelImpl()
        let ws: CharactersWebService = self.makeCharactersWebService()
        let repository: CharacterRespository = CharactersRepositoryImpl(webService: ws)
        let result: CharactersListViewModel = CharactersListViewModelImpl(model: model,
                                                                          repository: repository)
        return result
    }
    
    private func makeCharactersWebService() -> CharactersWebService {
        let cursor: CharactersWebService.Cursor =
            CharactersWebService.Cursor(resultsPerPage: CharactersWebService.Constants.resultsPerPage)
        let result: CharactersWebService = CharactersWebService(cursor: cursor)
        return result
    }
}
