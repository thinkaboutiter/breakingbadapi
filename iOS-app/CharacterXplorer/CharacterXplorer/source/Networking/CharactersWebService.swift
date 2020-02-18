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

typealias BreakingBadCharacterWebEntities = [BreakingBadCharacterWebEntity]

class CharactersWebService: BaseWebService<BreakingBadCharacterWebEntities> {
    
    // MARK: - Properties
    private var cursor: Cursor = Cursor(resultsPerPage: Constants.resultsPerPage)
    func resetCursor() {
        self.cursor.reset()
    }
    
    // MARK: - Initialization
    init() {
        Logger.success.message()
        super.init(endpoint: WebServiceConstants.Endpoint.characters)
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
    
    override func fetch(success: @escaping (BreakingBadCharacterWebEntities) -> Void,
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

private extension CharactersWebService {
    
    enum Constants {
        enum ParameterKey {
            static let limit: String = "limit"
            static let offset: String = "offset"
        }
        
        static let resultsPerPage: Int = 10
    }
}

fileprivate struct Cursor {
    
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
