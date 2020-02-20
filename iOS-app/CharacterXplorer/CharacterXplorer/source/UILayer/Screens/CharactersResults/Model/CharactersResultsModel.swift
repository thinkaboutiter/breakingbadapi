//
//  CharactersResultsModel.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-20-Feb-Thu.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

/// APIs for `ViewModel` to expose to `Model`
protocol CharactersResultsModelConsumer: AnyObject {}

/// APIs for `Model` to expose to `ViewModel`
protocol CharactersResultsModel: AnyObject {
    func setModelConsumer(_ newValue: CharactersResultsModelConsumer)
}

class CharactersResultsModelImpl: CharactersResultsModel {
    
    // MARK: - Properties
    private weak var modelConsumer: CharactersResultsModelConsumer!
    
    // MARK: - Initialization
    init() {
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersResultsModel protocol
    func setModelConsumer(_ newValue: CharactersResultsModelConsumer) {
        self.modelConsumer = newValue
    }
}
