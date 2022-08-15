//
//  MockRestRemote.swift
//  RemoteDoubles
//
//  Created by sudo.park on 2022/07/30.
//

import Foundation

import Remote
import Extensions

open class MockRestRemote: RestRemote, @unchecked Sendable {
    
    public init() { }
    
    public var findByIdResult: Result<Any, Error>?
    public var didRequestedFindByIds: [String] = []
    public var didRequestedFindByIDEndpoints: [RestAPIEndpoint] = []
    open func requestFind<J>(_ endpoint: RestAPIEndpoint, byID: String) async throws -> J where J : JsonMappable {
        
        self.didRequestedFindByIds.append(byID)
        self.didRequestedFindByIDEndpoints.append(endpoint)
        
        guard let result = self.findByIdResult,
              let value: J = try result.unwrapSuccessOrThrow()
        else {
            throw RuntimeError("not exists")
        }
        return value
    }
    
    public var findByQueryResult: Result<Any, Error>?
    public var didRequestedFindByQuerys: [LoadQuery] = []
    public var didRequestedFindByQueryEndpoints: [RestAPIEndpoint] = []
    open func requestFind<J>(_ endpoint: RestAPIEndpoint, byQuery: LoadQuery) async throws -> [J] where J : JsonMappable {
        
        self.didRequestedFindByQuerys.append(byQuery)
        self.didRequestedFindByQueryEndpoints.append(endpoint)
        
        guard let result = self.findByQueryResult,
              let values: [J] = try result.unwrapSuccessOrThrow()
        else {
            throw RuntimeError("not exists")
        }
        return values
    }
    
    public var saveResult: Result<Any, Error>?
    open func requestSave<J>(_ endpoint: RestAPIEndpoint, _ entities: [String : Any]) async throws -> J where J : JsonMappable {
        guard let result = self.saveResult,
              let value: J = try result.unwrapSuccessOrThrow()
        else {
            throw RuntimeError("not exists")
        }
        return value
    }
    
    public var batchSaveResult: Result<Void, Error> = .success(())
    open func requestBatchSaves(_ endpoint: RestAPIEndpoint, _ entities: [[String : Any]]) async throws {
        try self.batchSaveResult.throwOrNot()
    }
    
    public var batchUpdateResult: Result<Void, Error> = .success(())
    open func requestBatchUpdates(_ endpoint: RestAPIEndpoint, _ entities: [JsonPresentable]) async throws {
        try self.batchUpdateResult.throwOrNot()
    }
    
    public var updateResult: Result<Any, Error>?
    public var didRequestedUpdateIDs: [String] = []
    public var didRequestedUpdateTOJsons: [[String: Any]] = []
    public var didRequestedUpdateEndpoints: [RestAPIEndpoint] = []
    open func requestUpdate<J>(_ endpoint: RestAPIEndpoint, id: String, to: [String : Any]) async throws -> J where J : JsonMappable {
        
        self.didRequestedUpdateIDs.append(id)
        self.didRequestedUpdateTOJsons.append(to)
        self.didRequestedUpdateEndpoints.append(endpoint)
        
        guard let result = self.updateResult,
              let value: J = try result.unwrapSuccessOrThrow()
        else {
            throw RuntimeError("not exists")
        }
        return value
    }
    
    public var deleteResult: Result<Void, Error> = .success(())
    open func requestDelete(_ endpoint: RestAPIEndpoint, byId: String) async throws {
        try self.deleteResult.throwOrNot()
    }
    
    public var deleteByQueryResult: Result<Void, Error> = .success(())
    open func requestDelete(_ endpoint: RestAPIEndpoint, byQuery: MatcingQuery) async throws {
        try self.deleteByQueryResult.throwOrNot()
    }
    
    
    
}
