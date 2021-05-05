//
//  HttpRemote.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire


protocol HttpRemote {
    
    func requestData<T: Decodable>(_ endpoint: HttpAPIEndPoint) -> Maybe<T>
    func requestData<T: Decodable>(_ endpoint: HttpAPIEndPoint, parameters: [String: Any]) -> Maybe<T>
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

extension HttpRemote {
    
    func requestData<T: Decodable>(_ endpoint: HttpAPIEndPoint) -> Maybe<T> {
        return self.requestData(endpoint, parameters: [:])
    }
    
    func requestData<T: Decodable>(_ endpoint: HttpAPIEndPoint,
                                   parameters: [String: Any]) -> Maybe<T> {
        
        return Maybe.create { callback in
            let path = endpoint.path
            let method = endpoint.method.asAFMethod
            let headers = endpoint.customHeader.map{ HTTPHeaders($0) }
            var finalParams = endpoint.defaultParams ?? [:]
            parameters.forEach {
                finalParams[$0.key] = $0.value
            }
            
            let request = AF
                .request(path, method: method, parameters: finalParams, headers: headers)
                .responseData { response in
                    let decodeResult: Result<T, Error> = response.result.asDecodeResult()
                    switch decodeResult {
                    case let .success(model):
                        callback(.success(model))
                        
                    case let .failure(error):
                        callback(.error(error))
                    }
                }
            request.resume()
                
            return Disposables.create {
                request.cancel()
            }
        }
    }
}


private extension Result where Success == Data, Failure == AFError {
    
    func asDecodeResult<T: Decodable>() -> Result<T, Error> {
        
        let decodeResult: (Data) -> Result<T, Error> = { data in
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                return .success(model)
            } catch let error { return .failure(error)}
        }
        
        return self.mapError{ afError -> Error in afError }
            .flatMap(decodeResult)
    }
}
