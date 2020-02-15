//
//  CharactersListModel.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

/// APIs for `ViewModel` to expose to `Model`
protocol CharactersListModelConsumer: AnyObject {}

/// APIs for `Model` to expose to `ViewModel`
protocol CharactersListModel: AnyObject {
    func setModelConsumer(_ newValue: CharactersListModelConsumer)
}

class CharactersListModelImpl: CharactersListModel {
    
    // MARK: - Properties
    private weak var modelConsumer: CharactersListModelConsumer!
    
    // MARK: - Initialization
    init() {
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharactersListModel protocol
    func setModelConsumer(_ newValue: CharactersListModelConsumer) {
        self.modelConsumer = newValue
    }
}
