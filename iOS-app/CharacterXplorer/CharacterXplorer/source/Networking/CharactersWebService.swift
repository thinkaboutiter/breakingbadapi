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
    private var nextPage: Int = 0
    
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
        let offset: Int = self.nextPage * Constants.resultsPerPage
        let result: Parameters = [
            Constants.ParameterKey.limit: Constants.resultsPerPage,
            Constants.ParameterKey.offset: offset
        ]
        return result
    }
    
    override func fetch(success: @escaping (BreakingBadCharacterWebEntities) -> Void,
                        failure: @escaping (NSError) -> Void)
    {
        super.fetch(success: { (entities) in
            Logger.success.message("fetched page=\(self.nextPage)")
            self.nextPage += 1
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
