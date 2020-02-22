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
    
    // stub data
    let shouldUseStubData: Bool = true
    private lazy var stubCharacters: [BreakingBadCharacter] = {
        var result: [BreakingBadCharacter] = []
        do {
            result = try self.loadBundledCharacters()
        }
        catch {
            Logger.error.message().object(error as NSError)
        }
        return result
    }()

    
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
        if self.shouldUseStubData {
            result = self.stubCharacters
        }
        else {
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
        }
        return result
    }
}


// MARK: - Utils
private extension CharactersResultsModelImpl {
    
    func loadBundledCharacters() throws -> [BreakingBadCharacter] {
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
private extension CharactersResultsModelImpl {
    
    enum InternalError {
        static let domainName: String = "\(AppConstants.projectName).\(String(describing: CharactersResultsModelImpl.self)).\(String(describing: InternalError.self))"
        
        enum Code {
            static let unableToObtainFilePath: Int = 9000
        }
    }
}


// MARK: - Constants
private extension CharactersResultsModelImpl {
    enum Constants {
        static let concurrentQueueLabel: String = "\(AppConstants.projectName)-\(String(describing: CharactersResultsModelImpl.self))-concurrent-queue"
    }
}
