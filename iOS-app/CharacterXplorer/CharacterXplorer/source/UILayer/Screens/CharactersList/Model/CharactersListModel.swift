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
protocol CharactersListModelConsumer: AnyObject {
    func didUpdateCharacters(on model: CharactersListModel)
}

/// APIs for `Model` to expose to `ViewModel`
protocol CharactersListModel: AnyObject {
    func setModelConsumer(_ newValue: CharactersListModelConsumer)
    func addCharacters(_ collection: [BreakingBadCharacter])
    func characters() -> [BreakingBadCharacter]
}

class CharactersListModelImpl: CharactersListModel {
    
    // MARK: - Properties
    private weak var modelConsumer: CharactersListModelConsumer!
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
    
    // MARK: - CharactersListModel protocol
    func setModelConsumer(_ newValue: CharactersListModelConsumer) {
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

// MARK: - Utils
private extension CharactersListModelImpl {
    func loadCharacters() throws -> [BreakingBadCharacter] {
        let filename: String = "characters.json"
        guard let valid_filePath = Bundle.main.path(forResource: filename, ofType: nil) else {
            let message: String = NSLocalizedString("Unable to obtain filepath!", comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: InternalError.domainName,
                        code: InternalError.Code.unableToObtainFilePath,
                        localizedMessage: message)
                .error()
            throw error
        }
        let fileUrl: URL = URL(fileURLWithPath: valid_filePath)
        let jsonData: Data = try Data(contentsOf: fileUrl)
        let decoder: JSONDecoder = JSONDecoder()
        let result: [BreakingBadCharacter] = try decoder
            .decode([BreakingBadCharacterWebEntity].self,
                    from: jsonData)
            .map() { BreakingBadCharacterAppEntity(webEntity: $0) }
        return result
    }
}

// MARK: - Errors
private extension CharactersListModelImpl {
    
    enum InternalError {
        static let domainName: String = "\(AppConstants.projectName).\(String(describing: CharactersListModelImpl.self)).\(String(describing: InternalError.self))"
        
        enum Code {
            static let unableToObtainFilePath: Int = 9000
        }
    }
}

// MARK: - Constants
private extension CharactersListModelImpl {
    enum Constants {
        static let concurrentQueueLabel: String = "\(AppConstants.projectName)-\(String(describing: CharactersListModelImpl.self))-concurrent-queue"
    }
}
