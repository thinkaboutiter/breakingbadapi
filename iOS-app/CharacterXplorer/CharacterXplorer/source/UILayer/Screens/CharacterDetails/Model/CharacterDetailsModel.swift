//
//  CharacterDetailsModel.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

/// APIs for `ViewModel` to expose to `Model`
protocol CharacterDetailsModelConsumer: AnyObject {}

/// APIs for `Model` to expose to `ViewModel`
protocol CharacterDetailsModel: AnyObject {
    func setModelConsumer(_ newValue: CharacterDetailsModelConsumer)
}

class CharacterDetailsModelImpl: CharacterDetailsModel {
    
    // MARK: - Properties
    private weak var modelConsumer: CharacterDetailsModelConsumer!
    
    // MARK: - Initialization
    init() {
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharacterDetailsModel protocol
    func setModelConsumer(_ newValue: CharacterDetailsModelConsumer) {
        self.modelConsumer = newValue
    }
}
