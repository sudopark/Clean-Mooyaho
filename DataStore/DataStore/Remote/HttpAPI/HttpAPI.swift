//
//  HttpRemote.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics
import Alamofire

import Domain
import Extensions


// MARK: - wrpa alamofire session

public struct HttpResponse {
    let urlResponse: HTTPURLResponse?
    let dataResult: Result<Data, Error>
    
    public init(urlResponse: HTTPURLResponse?, dataResult: Result<Data, Error>) {
        self.urlResponse = urlResponse
        self.dataResult = dataResult
    }
}

public protocol HttpSession {
    
    func requestData(path: String, method: HttpAPIMethods, parameters: [String : Any], header: [String : String]?) -> Maybe<HttpResponse>
}

extension Session: HttpSession {
    
    public func requestData(path: String, method: HttpAPIMethods, parameters: [String : Any], header: [String : String]?) -> Maybe<HttpResponse> {
        
        return Maybe.create { callback in
            let encoding = method.encoding
            let method = method.asAFMethod
            let headers = header.map{ HTTPHeaders($0) }
            
            let handleResponse: (AFDataResponse<Data>) -> Void = { response in
                let dataResult = response.result.mapError{ afEror -> Error in afEror }
                let httpResponse = HttpResponse(urlResponse: response.response,
                                                dataResult: dataResult)
                callback(.success(httpResponse))
            }
            
            let request = self.request(path, method: method,
                                       parameters: parameters,
                                       encoding: encoding,
                                       headers: headers)
                .responseData(completionHandler: handleResponse)
            request.resume()

            return Disposables.create {
                request.cancel()
            }
        }
    }
}

// MARK: - HttpRemote Protocol

public protocol HttpAPI: AnyObject {
    
    var session: HttpSession { get }
    
    func requestData<T: Decodable>(_ type: T.Type, endpoint: HttpAPIEndPoint) -> Maybe<T>
    
    func requestData<T: Decodable>(_ type: T.Type, endpoint: HttpAPIEndPoint,
                                   parameters: [String: Any]) -> Maybe<T>
}

fileprivate let underlyingSession: HttpSession = Session(serializationQueue: DispatchQueue(label: "af.serialization", qos: .utility))

extension HttpAPI {
    
    public var session: HttpSession {
        
        return underlyingSession
    }
}

extension HttpAPIMethods {
    
    var asAFMethod: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .patch: return .patch
        case .delete: return .delete
        }
    }
}

extension HttpAPI {
    
    public func requestData<T: Decodable>(_ type: T.Type,
                                          endpoint: HttpAPIEndPoint) -> Maybe<T> {
        
        let result: Maybe<T> = self.requestData(type, endpoint: endpoint, parameters: [:])
        return result
    }
    
    public func requestData<T: Decodable>(_ type: T.Type,
                                          endpoint: HttpAPIEndPoint,
                                          parameters: [String: Any]) -> Maybe<T> {
        
        let path = endpoint.path
        var finalParams = endpoint.defaultParams ?? [:]
        parameters.forEach {
            finalParams[$0.key] = $0.value
        }
        
        let decode: (HttpResponse) throws -> T = { response in
            
            let code = response.urlResponse?.statusCode ?? -1
            logger.print(level: .debug, "status code: \(code)")
            let secureMessage = SecureLoggingMessage()
                |> \.fullText .~ "url path: %@"
                |> \.secureField .~ [response.urlResponse?.url?.path ?? ""]
            logger.print(level: .debug, secureMessage)
            
            let decodeResult: Result<T, Error> = response.dataResult.asDecodeResult()
            switch decodeResult {
            case let .success(model): return model
            case let .failure(error): throw error
            }
        }
        
        return self.session
            .requestData(path: path, method: endpoint.method,
                         parameters: finalParams, header: endpoint.customHeader)
            .map(decode)
    }
    
    public func requestResult(_ endpoint: HttpAPIEndPoint, parameters: [String: Any]) -> Maybe<Void> {
        
        var finalParams = endpoint.defaultParams ?? [:]
        parameters.forEach {
            finalParams[$0.key] = $0.value
        }
        
        return self.session
            .requestData(path: endpoint.path, method: endpoint.method,
                         parameters: finalParams, header: endpoint.customHeader)
            .map{ _ in }
    }
}


private extension Result where Success == Data, Failure == Error {
    
    func asDecodeResult<T: Decodable>() -> Result<T, Error> {
        
        let decodeResult: (Data) -> Result<T, Error> = { data in
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                return .success(model)
            } catch let error { return .failure(error)}
        }
        
        return self.flatMap(decodeResult)
    }
}

private extension HttpAPIMethods {
    
    var encoding: ParameterEncoding {
        switch self {
        case .post, .patch: return JSONEncoding.default
        default: return URLEncoding(arrayEncoding: .noBrackets)
        }
    }
}
