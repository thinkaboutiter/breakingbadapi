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
    func reloadCharacters()
}

/// APIs for `ViewModel` to expose to `View`
protocol CharactersResultsViewModel: AnyObject {
    func setViewModelConsumer(_ newValue: CharactersResultsViewModelConsumer)
    func getCharactes() -> [BreakingBadCharacter]
    func character(for indexPath: IndexPath) throws -> BreakingBadCharacter
    func getCharacterByName(_ name: String)
    func setSelectedSeason(_ newValue: BreakingBadSeason)
}

class CharactersResultsViewModelImpl: CharactersResultsViewModel, CharactersResultsModelConsumer {
    
    // MARK: - Properties
    private let model: CharactersResultsModel
    private let repository: CharacterRespository
    private weak var viewModelConsumer: CharactersResultsViewModelConsumer!
    private var filteredCharactes: [BreakingBadCharacter] = []
    private var searchText: String = ""
    private var selectedSeason: BreakingBadSeason = .allSeasons
    func setSelectedSeason(_ newValue: BreakingBadSeason) {
        self.selectedSeason = newValue
        self.fetchCharactersIfNeeded()
    }
    
    // MARK: - Initialization
    required init(model: CharactersResultsModel,
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
    
    // MARK: - CharactersResultsViewModel protocol
    func setViewModelConsumer(_ newValue: CharactersResultsViewModelConsumer) {
        self.viewModelConsumer = newValue
    }
    
    func getCharactes() -> [BreakingBadCharacter] {
        var result: [BreakingBadCharacter] = self.model.characters()
        if !self.searchText.isEmpty {
            self.filter(&result, by: self.searchText)
        }
        if self.selectedSeason != .allSeasons {
            self.filter(&result, by: self.selectedSeason)
        }
        return result
    }
    
    private func filter(_ collection: inout [BreakingBadCharacter],
                        by term: String)
    {
        collection = collection
            .filter() { $0.name.lowercased().contains(term.lowercased()) }
    }
    
    private func filter(_ collection: inout [BreakingBadCharacter],
                        by season: BreakingBadSeason)
    {
        collection = collection.filter() { $0.seasonAppearance.contains(season.rawValue) }
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
    
    func getCharacterByName(_ name: String) {
        self.searchText = name
        self.fetchCharactersIfNeeded()
    }
    
    private func fetchCharactersIfNeeded() {
        if self.model.characters().isEmpty {
            // Unfortunately the API that provides search for character by his/her name
            // supports that only for full name. See: https://breakingbadapi.com/Documentation
            // So we need to fetch all chars and manually filter :(
            // We are lucky that there are only 63 of them not 1_000_000 :)
            self.repository.fetchCharacters()
        }
        else {
            self.viewModelConsumer.reloadCharacters()
        }
    }
    
    // MARK: - CharactersResultsModelConsumer protocol
    func didUpdateCharacters(on model: CharactersResultsModel) {
        self.viewModelConsumer.reloadCharacters()
    }
}

// MARK: - CharacterRespositoryConsumer protocol
extension CharactersResultsViewModelImpl: CharacterRespositoryConsumer {
    
    func didFetchCharacters(on repository: CharacterRespository) {
        let characters: [BreakingBadCharacter] = repository.flushCharacters()
        self.model.addCharacters(characters)
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
