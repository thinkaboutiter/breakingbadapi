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
protocol CharactersResultsViewModelConsumer: AnyObject {}

/// APIs for `ViewModel` to expose to `View`
protocol CharactersResultsViewModel: AnyObject {
    func setViewModelConsumer(_ newValue: CharactersResultsViewModelConsumer)
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
    
    // MARK: - CharactersResultsModelConsumer protocol
}

