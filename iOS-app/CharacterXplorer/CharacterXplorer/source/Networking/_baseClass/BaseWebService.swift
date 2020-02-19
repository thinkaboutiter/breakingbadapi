//
//  BaseWebService.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-17-Feb-Mon.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger
import Alamofire

/// WebService protocol.
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
    
    /// Add parameters to the request.
    func requestParameters() -> Parameters?
    
    /// Request parameters encoding.
    func requestParametersEncoding() -> Alamofire.ParameterEncoding
    
    /// Response json reading options.
    func responseJSONReadingOptions() -> JSONSerialization.ReadingOptions
}

/// Abstract.
/// Subclass to create web service object.
class BaseWebService<T: Decodable>: WebService {
    
    // MARK: - Properties
    let endpoint: WebServiceConstants.Endpoint
    var request: Alamofire.Request?
    
    // MARK: - Initialization
    init(endpoint: WebServiceConstants.Endpoint) {
        self.endpoint = endpoint
    }
    
    // MARK: - WebService protocol
    static func baseEndpoint() -> String {
        let result: String = "\(WebServiceConstants.HttpPrefix.secure)\(WebServiceConstants.domain)"
        return result
    }
    
    func instanceEndpoint() -> String {
        return self.endpoint.rawValue
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
    
    func requestParameters() -> Parameters? {
        return nil
    }
    
    func requestParametersEncoding() -> ParameterEncoding {
        return URLEncoding.default
    }
    
    func responseJSONReadingOptions() -> JSONSerialization.ReadingOptions {
        return JSONSerialization.ReadingOptions.mutableContainers
    }
    
    // MARK: - Fetching
    func fetch(success: @escaping (_ responseObject: T) -> Void,
               failure: @escaping (_ error: NSError) -> Void)
    {
        self.request?.cancel()
        self.request = Alamofire
            .request(
                self.serviceEndpoint(),
                method: self.httpVerb(),
                parameters: self.requestParameters(),
                encoding: self.requestParametersEncoding(),
                headers: self.requestHeaders())
            .responseData(completionHandler: { (response: DataResponse<Data>) in
                Logger.network.message("request:").object(response.request)
                Logger.network.message("request.allHTTPHeaderFields:").object(response.request?.allHTTPHeaderFields)
                Logger.network.message("response:").object(response.response)
                Logger.network.message("timeline:").object(response.timeline)
                do {
                    try self.validateResponse(response)
                    
                    guard let valid_responseData: Data = response.result.value else {
                        let message: String = NSLocalizedString("Unable to obtain response object!",
                                                                comment: AppConstants.LocalizedStringComment.errorMessage)
                        let error: NSError = ErrorCreator
                            .custom(domain: BaseWebServiceError.domainName,
                                    code: BaseWebServiceError.Code.unableToObtainResponseObject,
                                    localizedMessage: message)
                            .error()
                        failure(error)
                        return
                    }
                    let decoder: JSONDecoder = JSONDecoder()
                    let result: T = try decoder.decode(T.self, from: valid_responseData)
                    success(result)
                }
                catch {
                    failure(error as NSError)
                }
            })
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
                .custom(domain: BaseWebServiceError.domainName,
                        code: BaseWebServiceError.Code.invalidResponseObject,
                        localizedMessage: message)
                .error()
            throw error
        }
        
        // check status code
        guard 200...299 ~= valid_response.statusCode else {
            let message: String = NSLocalizedString("Invalid status code=\(valid_response.statusCode)",
                                                    comment: AppConstants.LocalizedStringComment.errorMessage)
            let error: NSError = ErrorCreator
                .custom(domain: BaseWebServiceError.domainName,
                        code: BaseWebServiceError.Code.invalidStatusCode,
                        localizedMessage: message)
                .error()
            throw error
        }
    }
}

// MARK: - Constants
enum WebServiceConstants {
    
    static let domain: String = "breakingbadapi.com"
    
    enum HttpPrefix {
        static let secure: String = "https://"
    }
    
    enum Endpoint: String {
        case characters = "/api/characters"
    }
}

// MARK: - Errors
private enum BaseWebServiceError {
    static let domainName: String = "\(AppConstants.projectName).\(String(describing: BaseWebServiceError.self))"
    
    enum Code {
        static let invalidResponseObject: Int = 9000
        static let invalidStatusCode: Int = 9001
        static let unableToObtainResponseObject: Int = 9002
    }
}
