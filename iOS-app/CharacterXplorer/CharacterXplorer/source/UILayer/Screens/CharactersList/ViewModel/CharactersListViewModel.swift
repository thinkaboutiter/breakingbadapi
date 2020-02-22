//
//  CharactersListViewModel.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

/// APIs for `View` to expose to `ViewModel`
protocol CharactersListViewModelConsumer: AnyObject {
    func reloadCharacters()
}

/// APIs for `ViewModel` to expose to `View`
protocol CharactersListViewModel: AnyObject {
    func setViewModelConsumer(_ newValue: CharactersListViewModelConsumer)
    func fetchCharacters()
    func getCharactes() -> [BreakingBadCharacter]
    func character(for indexPath: IndexPath) throws -> BreakingBadCharacter
    func refreshCharacters()
}

class CharactersListViewModelImpl: CharactersListViewModel, CharactersListModelConsumer {
    
    // MARK: - Properties
    private let model: CharactersListModel
    private let repository: CharacterRespository
    private weak var viewModelConsumer: CharactersListViewModelConsumer!
    
    // MARK: - Initialization
    required init(model: CharactersListModel,
                  repository: CharacterRespository)
    {
        self.model = model
        self.repository = repository
        self.model.setModelConsumer(self)
        self.repository.setRepositoryConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListViewModel protocol
    func setViewModelConsumer(_ newValue: CharactersListViewModelConsumer) {
        self.viewModelConsumer = newValue
    }
    
    func fetchCharacters() {
        self.repository.fetchCharacters()
    }
    
    func getCharactes() -> [BreakingBadCharacter] {
        return self.model.characters()
    }
    
    func character(for indexPath: IndexPath) throws -> BreakingBadCharacter {
        let index: Int = indexPath.row
        let characters: [BreakingBadCharacter] = self.getCharactes()
        let range: Range<Int> = 0..<characters.count
        guard range ~= index else {
            let message: String = NSLocalizedString("Index out of bounds!",
                                                    comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: InternalError.domainName,
                        code: InternalError.Code.indexOutOfBounds,
                        localizedMessage: message)
                .error()
            
            throw error
        }
        let result: BreakingBadCharacter = characters[index]
        return result
    }
    
    func refreshCharacters() {
        self.model.clearAllCharacters()
        self.repository.refresh()
    }
    
    // MARK: - CharactersListModelConsumer protocol
    func didUpdateCharacters(on model: CharactersListModel) {
        self.viewModelConsumer.reloadCharacters()
    }
}

// MARK: - CharacterRespositoryConsumer protocol
extension CharactersListViewModelImpl: CharacterRespositoryConsumer {
    
    func didFetchCharacters(on repository: CharacterRespository) {
        let characters: [BreakingBadCharacter] = repository.flushCharacters()
        self.model.addCharacters(characters)
    }
}

// MARK: - Internal Errors
private extension CharactersListViewModelImpl {
    
    enum InternalError {
        static let domainName: String = "\(AppConstants.projectName).\(String(describing: CharactersListViewModelImpl.self)).\(String(describing: InternalError.self))"
        
        enum Code {
            static let indexOutOfBounds: Int = 9000
        }
    }
}
