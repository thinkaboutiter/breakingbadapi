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
    func characters() -> [BreakingBadCharacter]
}

class CharactersListModelImpl: CharactersListModel {
    
    // MARK: - Properties
    private weak var modelConsumer: CharactersListModelConsumer!
    private lazy var _characters: [BreakingBadCharacter] = {
        var result: [BreakingBadCharacter] = []
        do {
            result = try self.loadCharacters()
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
    
    // MARK: - CharactersListModel protocol
    func setModelConsumer(_ newValue: CharactersListModelConsumer) {
        self.modelConsumer = newValue
    }
    
    func characters() -> [BreakingBadCharacter] {
        return self._characters
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
