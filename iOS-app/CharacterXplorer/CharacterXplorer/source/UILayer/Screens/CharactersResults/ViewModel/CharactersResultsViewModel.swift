//
//  CharactersResultsViewModel.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-20-Feb-Thu.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

/// APIs for `View` to expose to `ViewModel`
protocol CharactersResultsViewModelConsumer: AnyObject {
    func reloadCharacters(via viewModel: CharactersResultsViewModel)
}

/// APIs for `ViewModel` to expose to `View`
protocol CharactersResultsViewModel: AnyObject {
    func setViewModelConsumer(_ newValue: CharactersResultsViewModelConsumer)
    func getCharactes() -> [BreakingBadCharacter]
    func character(for indexPath: IndexPath) throws -> BreakingBadCharacter
}

class CharactersResultsViewModelImpl: CharactersResultsViewModel, CharactersResultsModelConsumer {
    
    // MARK: - Properties
    private let model: CharactersResultsModel
    private weak var viewModelConsumer: CharactersResultsViewModelConsumer!
    
    // MARK: - Initialization
    required init(model: CharactersResultsModel) {
        self.model = model
        self.model.setModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersResultsViewModel protocol
    func setViewModelConsumer(_ newValue: CharactersResultsViewModelConsumer) {
        self.viewModelConsumer = newValue
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
    
    // MARK: - CharactersResultsModelConsumer protocol
    func didUpdateCharacters(on model: CharactersResultsModel) {
        self.viewModelConsumer.reloadCharacters(via: self)
    }
}

// MARK: - Internal Errors
private extension CharactersResultsViewModelImpl {
    
    enum InternalError {
        static let domainName: String = "\(AppConstants.projectName).\(String(describing: CharactersResultsViewModelImpl.self)).\(String(describing: InternalError.self))"
        
        enum Code {
            static let indexOutOfBounds: Int = 9000
        }
    }
}
