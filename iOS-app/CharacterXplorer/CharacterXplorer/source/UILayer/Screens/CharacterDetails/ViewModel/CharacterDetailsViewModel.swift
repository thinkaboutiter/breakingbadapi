//
//  CharacterDetailsViewModel.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

/// APIs for `View` to expose to `ViewModel`
protocol CharacterDetailsViewModelConsumer: AnyObject {}

/// APIs for `ViewModel` to expose to `View`
protocol CharacterDetailsViewModel: AnyObject {
    func setViewModelConsumer(_ newValue: CharacterDetailsViewModelConsumer)
    func getCharacter() -> BreakingBadCharacter
}

class CharacterDetailsViewModelImpl: CharacterDetailsViewModel, CharacterDetailsModelConsumer {
    
    // MARK: - Properties
    private let model: CharacterDetailsModel
    private weak var viewModelConsumer: CharacterDetailsViewModelConsumer!
    
    // MARK: - Initialization
    required init(model: CharacterDetailsModel) {
        self.model = model
        self.model.setModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharacterDetailsViewModel protocol
    func setViewModelConsumer(_ newValue: CharacterDetailsViewModelConsumer) {
        self.viewModelConsumer = newValue
    }
    
    func getCharacter() -> BreakingBadCharacter {
        let result: BreakingBadCharacter = self.model.character()
        return result
    }
    
    // MARK: - CharacterDetailsModelConsumer protocol
}

