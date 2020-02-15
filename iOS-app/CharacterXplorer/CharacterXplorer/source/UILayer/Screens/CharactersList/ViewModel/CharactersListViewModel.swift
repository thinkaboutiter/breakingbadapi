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
}

/// APIs for `ViewModel` to expose to `View`
protocol CharactersListViewModel: AnyObject {
    func setViewModelConsumer(_ newValue: CharactersListViewModelConsumer)
    func getCharactes() -> [BreakingBadCharacter]
}

class CharactersListViewModelImpl: CharactersListViewModel, CharactersListModelConsumer {
    
    // MARK: - Properties
    private let model: CharactersListModel
    private weak var viewModelConsumer: CharactersListViewModelConsumer!
    
    // MARK: - Initialization
    required init(model: CharactersListModel) {
        self.model = model
        self.model.setModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListViewModel protocol
    func setViewModelConsumer(_ newValue: CharactersListViewModelConsumer) {
        self.viewModelConsumer = newValue
    }
    
    func getCharactes() -> [BreakingBadCharacter] {
        return self.model.characters()
    }
    
    // MARK: - CharactersListModelConsumer protocol
}

