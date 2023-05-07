//
//  RestRemote.swift
//  Remote
//
//  Created by sudo.park on 2022/07/12.
//

import Foundation
import Prelude
import Optics


// MARK: - Queries

public struct MatcingQuery {
    
    public enum Relateion {
        case equal
        case notEqual
        case greaterThan
        case greaterThanOrEqual
        case lessThan
        case lessThanOrEqual
        case `in`
        case notIn
    }
    
    public struct Condition {
        public let field: String
        public let relatation: Relateion
        public let value: Any
        
        public init(_ field: String, _ relation: Relateion, _ value: Any) {
            self.field = field
            self.relatation = relation
            self.value = value
        }
    }
    
    public var conditions: [Condition] = []
    
    public init() { }
    
    public func `where`(_ condition: Condition) -> MatcingQuery {
        return self
            |> \.conditions %~ { $0 + [condition] }
    }
    
}

public struct LoadQuery {
    
    public enum Order {
        case asc(String)
        case desc(String)
    }
    
    public var matchingQuery: MatcingQuery = .init()
    public var orders: [Order] = []
    public var limit: Int?
    
    public func `where`(_ condition: MatcingQuery.Condition) -> LoadQuery {
        return self
            |> \.matchingQuery %~ { $0.where(condition) }
    }
    
    public func order(_ order: Order) -> LoadQuery {
        return self
            |> \.orders %~ { $0 + [order] }
    }
    
    public init() {}
}

public enum UpdateList {
    case union(elements: [Any])
    case remove(elements: [Any])
}


// MARK: - RestRemote

public protocol RestRemote: Sendable {
    
    // id로 조회
    func requestFind<J: JsonMappable>(
        _ endpoint: RestAPIEndpoint,
        byID: String
    ) async throws -> J
    
    // query로 조회
    func requestFind<J: JsonMappable>(
        _ endpoint: RestAPIEndpoint,
        byQuery: LoadQuery
    ) async throws -> [J]
    
    // 새로운값 저장
    func requestSave<J: JsonMappable>(
        _ endpoint: RestAPIEndpoint,
        _ entities: [String: Any]
    ) async throws -> J
    
    func requestBatchSaves(
        _ endpoint: RestAPIEndpoint,
        _ entities: [[String: Any]]
    ) async throws
    
    func requestBatchUpdates(
        _ endpoint: RestAPIEndpoint,
        _ entities: [JsonPresentable]
    ) async throws
    
    // 특정 데이터 업데이트
    func requestUpdate<J: JsonMappable>(
        _ endpoint: RestAPIEndpoint,
        id: String,
        to: [String: Any]
    ) async throws -> J
    
    func requestDelete(
        _ endpoint: RestAPIEndpoint,
        byId: String
    ) async throws
    
    func requestDelete(
        _ endpoint: RestAPIEndpoint,
        byQuery: MatcingQuery
    ) async throws
}



private extension MatcingQuery.Relateion {
    
    var stringValue: String {
        switch self {
        case .equal: return "="
        case .notEqual: return "!="
        case .greaterThan: return ">"
        case .greaterThanOrEqual: return ">="
        case .lessThan: return "<"
        case .lessThanOrEqual: return "<="
        case .in: return "in"
        case .notIn: return "not in"
        }
    }
}

extension MatcingQuery.Condition {
    
    public var stringValue: String {
        return "\(field) \(relatation.stringValue) \(value)"
    }
}
