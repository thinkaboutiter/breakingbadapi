//
//  CharactersWebService.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-17-Feb-Mon.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger
import Alamofire

class CharactersWebService: BaseWebService<[BreakingBadCharacterWebEntity]> {
    
    // MARK: - Properties
    private var cursor: Cursor
    func resetCursor() {
        self.cursor.reset()
    }
    
    // MARK: - Initialization
    required init(cursor: Cursor) {
        self.cursor = cursor
        super.init(endpoint: WebServiceConstants.Endpoint.characters)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - WebService protocol
    override func requestParameters() -> Parameters? {
        let result: Parameters = [
            Constants.ParameterKey.limit: self.cursor.resultsPerPage,
            Constants.ParameterKey.offset: self.cursor.offset
        ]
        return result
    }
    
    override func fetch(success: @escaping ([BreakingBadCharacterWebEntity]) -> Void,
                        failure: @escaping (NSError) -> Void)
    {
        guard self.cursor.hasNext else {
            let message: String = "Rreached end of List."
            Logger.warning.message(message)
            return
        }
        super.fetch(
            success: { (entities) in
                Logger.success.message("fetched page=\(self.cursor.page)")
                self.cursor.update(withNumberOfResults: entities.count)
                success(entities)
        },
            failure: failure)
    }
}

// MARK: - Constants
extension CharactersWebService {
    
    enum Constants {
        fileprivate enum ParameterKey {
            static let limit: String = "limit"
            static let offset: String = "offset"
        }
        
        static let resultsPerPage: Int = 20
    }
}

// MARK: - Cursor
extension CharactersWebService {
    
    struct Cursor {
        
        // MARK: - Properties
        let resultsPerPage: Int
        private(set) var page = 0
        private(set) var hasNext: Bool = true
        var offset: Int {
            return self.page * self.resultsPerPage
        }
        
        // MARK: - Initialization
        init(resultsPerPage: Int) {
            self.resultsPerPage = resultsPerPage
        }
        
        // MARK: - Business
        mutating func reset() {
            self.page = 0
            self.hasNext = true
        }
        
        mutating func update(withNumberOfResults count: Int) {
            if count != 0
                && count == self.resultsPerPage
            {
                self.page += 1
            }
            else {
                self.hasNext = false
            }
        }
    }
}
