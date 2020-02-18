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
    func consumeCharacters() -> [BreakingBadCharacter]
    func setConsumer(_ newValue: CharacterRespositoryConsumer)
    func fetchCharacters()
    func reset()
}

class CharactersRepositoryImpl: CharacterRespository {
    
    // MARK: - Properties
    private let webService: CharactersWebService
    private weak var consumer: CharacterRespositoryConsumer!
    private var cache: NSMutableOrderedSet = []
    
    // MARK: - Initialization
    init(webService: CharactersWebService) {
        self.webService = webService
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharacterRespository
    func consumeCharacters() -> [BreakingBadCharacter] {
        let result: [BreakingBadCharacter] = self.cache.compactMap { (element: Any) -> BreakingBadCharacter? in
            guard let valid_entity: BreakingBadCharacterAppEntity = element as? BreakingBadCharacterAppEntity else {
                return nil
            }
            return valid_entity
        }
        let message: String = "Consuming \(result.count) \(String(describing: BreakingBadCharacter.self))-s"
        Logger.debug.message(message)
        self.cache.removeAllObjects()
        return result
    }
    
    func setConsumer(_ newValue: CharacterRespositoryConsumer) {
        self.consumer = newValue
    }
    
    func fetchCharacters() {
        self.webService.fetch(success: { (entities: [BreakingBadCharacterWebEntity]) in
            let characters: [BreakingBadCharacterAppEntity] = entities.map() { BreakingBadCharacterAppEntity(webEntity: $0) }
            self.cache.addObjects(from: characters)
            self.consumer.didFetchCharacters(on: self)
        }) { (error: NSError) in
            Logger.error.message().object(error)
        }
    }
    
    func reset() {
        self.webService.resetCursor()
        self.cache.removeAllObjects()
    } 
}
