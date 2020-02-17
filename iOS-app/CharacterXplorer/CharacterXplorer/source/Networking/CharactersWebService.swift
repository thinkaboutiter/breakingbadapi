//
//  CharactersWebService.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-17-Feb-Mon.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import Alamofire

typealias BreakingBadCharacterWebEntities = [BreakingBadCharacterWebEntity]

class CharactersWebService: BaseWebService<BreakingBadCharacterWebEntities> {
    
    // MARK: - Initialization
    init() {
        super.init(endpoint: WebServiceConstants.Endpoint.characters)
    }
    
    // MARK: - WebService protocol
    override func requestParameters() -> Parameters? {
        let result: Parameters = [
            Constants.ParameterKey.limit: Constants.resultsPerPage,
            Constants.ParameterKey.offset: Constants.initialOffset
        ]
        return result
    }
}

private extension CharactersWebService {
    
    enum Constants {
        enum ParameterKey {
            static let limit: String = "limit"
            static let offset: String = "offset"
        }
        
        static let resultsPerPage: Int = 10
        static let initialOffset: Int = 0
    }
}
