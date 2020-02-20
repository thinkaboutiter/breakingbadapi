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
protocol CharactersResultsModelConsumer: AnyObject {
    func didUpdateCharacters(on model: CharactersResultsModel)
}

/// APIs for `Model` to expose to `ViewModel`
protocol CharactersResultsModel: AnyObject {
    func setModelConsumer(_ newValue: CharactersResultsModelConsumer)
    func addCharacters(_ collection: [BreakingBadCharacter])
    func characters() -> [BreakingBadCharacter]
}

class CharactersResultsModelImpl: CharactersResultsModel {
    
    // MARK: - Properties
    private weak var modelConsumer: CharactersResultsModelConsumer!
    private let concurrentCacheQueue = DispatchQueue(label: Constants.concurrentQueueLabel,
                                                     qos: .default,
                                                     attributes: .concurrent)
    private lazy var cache: NSMutableOrderedSet = []
    
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
    
    func addCharacters(_ collection: [BreakingBadCharacter]) {
           self.concurrentCacheQueue
               .async(qos: .default,
                      flags: .barrier)
               { [weak self] in
                   guard let valid_self = self else {
                       return
                   }
                   valid_self.cache.addObjects(from: collection)
                   DispatchQueue.main.async { [weak self] in
                       guard let valid_self = self else {
                           return
                       }
                       valid_self.modelConsumer.didUpdateCharacters(on: valid_self)
                   }
           }
       }
    
    func characters() -> [BreakingBadCharacter] {
        var result: [BreakingBadCharacter]!
        self.concurrentCacheQueue.sync { [weak self] in
            guard let valid_self = self else {
                return
            }
            result = valid_self.cache.compactMap { (element: Any) -> BreakingBadCharacter? in
                guard let valid_entity: BreakingBadCharacterAppEntity = element as? BreakingBadCharacterAppEntity else {
                    return nil
                }
                return valid_entity
            }
        }
        return result
    }
}

// MARK: - Constants
private extension CharactersResultsModelImpl {
    enum Constants {
        static let concurrentQueueLabel: String = "\(AppConstants.projectName)-\(String(describing: CharactersResultsModelImpl.self))-concurrent-queue"
    }
}
