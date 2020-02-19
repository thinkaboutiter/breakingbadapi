//
//  CharacterRepository.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-18-Feb-Tue.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol CharacterRespositoryConsumer: AnyObject {
    func didFetchCharacters(on repository: CharacterRespository)
}

protocol CharacterRespository: AnyObject {
    func flushCharacters() -> [BreakingBadCharacter]
    func setRepositoryConsumer(_ newValue: CharacterRespositoryConsumer)
    func fetchCharacters()
    func refresh()
}

class CharactersRepositoryImpl: CharacterRespository {
    
    // MARK: - Properties
    private let webService: CharactersWebService
    private weak var consumer: CharacterRespositoryConsumer!
    private let concurrentCacheQueue = DispatchQueue(label: Constants.concurrentQueueLabel,
                                                     qos: .default,
                                                     attributes: .concurrent)
    private var cache: NSMutableOrderedSet = []
    private func clearCache() {
        self.concurrentCacheQueue
            .async(qos: .default,
                   flags: .barrier)
            { [weak self] in
                guard let valid_self = self else {
                    return
                }
                valid_self.cache.removeAllObjects()
        }
    }
    
    // MARK: - Initialization
    init(webService: CharactersWebService) {
        self.webService = webService
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharacterRespository
    func flushCharacters() -> [BreakingBadCharacter] {
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
        
        defer {
            let message: String = "Flushed \(result.count) \(String(describing: BreakingBadCharacter.self))-s"
            Logger.debug.message(message)
            self.clearCache()
        }
        return result
    }
    
    func setRepositoryConsumer(_ newValue: CharacterRespositoryConsumer) {
        self.consumer = newValue
    }
    
    func fetchCharacters() {
        self.webService.fetch(success: { (entities: [BreakingBadCharacterWebEntity]) in
            let characters: [BreakingBadCharacterAppEntity] = entities.map() { BreakingBadCharacterAppEntity(webEntity: $0) }
            self.consume(characters)
        }) { (error: NSError) in
            Logger.error.message().object(error)
        }
    }
    
    private func consume(_ characters: [BreakingBadCharacterAppEntity]) {
        self.concurrentCacheQueue
            .async(qos: .default,
                   flags: .barrier)
            { [weak self] in
                guard let valid_self = self else {
                    return
                }
                valid_self.cache.addObjects(from: characters)
                DispatchQueue.main.async { [weak self] in
                    guard let valid_self = self else {
                        return
                    }
                    valid_self.consumer.didFetchCharacters(on: valid_self)
                }
        }
    }
    
    func refresh() {
        self.clearCache()
        self.webService.resetCursor()
        self.fetchCharacters()
    }
}

// MARK: - Constants
private extension CharactersRepositoryImpl {
    enum Constants {
        static let concurrentQueueLabel: String = "\(AppConstants.projectName)-\(String(describing: CharactersRepositoryImpl.self))-concurrent-queue"
    }
}
