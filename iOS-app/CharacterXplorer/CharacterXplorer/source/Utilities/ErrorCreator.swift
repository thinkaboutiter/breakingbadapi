//
//  ErrorCreator.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation

enum ErrorCreator {
    case generic
    case custom(domain: String, code: Int, localizedMessage: String)
    
    static let domain: String = "ApplicationError"
    
    func error() -> NSError {
        switch self {
        case .generic:
            return self.error(domain: Constatns.errorDomainName,
                              code: Constatns.errorCode,
                              message: Constatns.errorMessage)
            
        case .custom(let domain, let code, let message):
            return self.error(domain: domain,
                              code: code,
                              message: message)
        }
    }
    
    fileprivate func error(domain: String, code: Int, message: String) -> NSError {
        let error: NSError = NSError(
            domain: domain,
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: message
            ])
        
        return error
    }
}

// MARK: - Constants
private extension ErrorCreator {
    
    enum Constatns {
        static let errorDomainName: String = "Application.GenericError"
        static let errorCode: Int = 8999
        static let errorMessage: String = "I've got a bad feeling about this."
    }
}
