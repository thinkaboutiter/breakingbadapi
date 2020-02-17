//
//  BaseWebService.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-17-Feb-Mon.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import Alamofire

protocol WebService {
    
    /// Base endpoint for all services.
    static func baseEndpoint() -> String
    
    /// Endpoint for particular web service instance.
    func instanceEndpoint() -> String
    
    /// Complete endpoint.
    func serviceEndpoint() -> String
    
    /// Http verb.
    func httpVerb() -> Alamofire.HTTPMethod
    
    /// Request headers.
    func requestHeaders() -> [String: String]?
    
    /// Request parameters encoding.
    func requestParametersEncoding() -> Alamofire.ParameterEncoding
    
    /// Response json reading options.
    func responseJSONReadingOptions() -> JSONSerialization.ReadingOptions
}

/// Abstract.
/// Subclass to create web service object.
class BaseWebService: WebService {
    
    // MARK: - Properties
    let endpoint: Endpoint
    var request: Alamofire.Request?
    
    // MARK: - Initialization
    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }
    
    // MARK: - WebService protocol
    static func baseEndpoint() -> String {
        let result: String = "\(HttpPrefix.secure)\(Constants.domain)"
        return result
    }
    
    func instanceEndpoint() -> String {
        return ""
    }
    
    func serviceEndpoint() -> String {
        let baseEndpoint: String = type(of: self).baseEndpoint()
        let instanceEndpoint: String = self.instanceEndpoint()
        let result: String = "\(baseEndpoint)\(instanceEndpoint)"
        return result
    }
    
    func httpVerb() -> HTTPMethod {
        return .get
    }
    
    func requestHeaders() -> [String : String]? {
        return nil
    }
    
    func requestParametersEncoding() -> ParameterEncoding {
        return URLEncoding.default
    }
    
    func responseJSONReadingOptions() -> JSONSerialization.ReadingOptions {
        return JSONSerialization.ReadingOptions.mutableContainers
    }
    
    // MARK: - Validation
    func validateResponse<T>(_ response: DataResponse<T>) throws {
        // check for error
        guard response.result.error == nil else {
            throw response.result.error! as NSError
        }
        
        // check response object
        guard let valid_response: HTTPURLResponse = response.response else {
            let message: String = NSLocalizedString("Invalid response object",
                                                    comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: InternalError.domainName,
                        code: InternalError.Code.invalidResponseObject,
                        localizedMessage: message)
                .error()
            throw error
        }
        
        // check status code
        guard 200...299 ~= valid_response.statusCode else {
            let message: String = NSLocalizedString("Invalid status code=\(valid_response.statusCode)",
                                                    comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: InternalError.domainName,
                        code: InternalError.Code.invalidStatusCode,
                        localizedMessage: message)
                .error()
            throw error
        }
    }
}

// MARK: - Constants
extension BaseWebService {
    enum Constants {
        static let domain: String = "breakingbadapi.com"
    }
    
    enum HttpPrefix {
        static let secure: String = "https://"
    }
    
    enum Endpoint: String {
        case characters = "/api/characters"
    }
}

// MARK: - Errors
private extension BaseWebService {
    
    enum InternalError {
        static let domainName: String = "\(AppConstants.projectName).\(String(describing: BaseWebService.self)).\(String(describing: InternalError.self))"
        
        enum Code {
            static let invalidResponseObject: Int = 9000
            static let invalidStatusCode: Int = 9001
        }
    }
}
