//
//  FirebaseQueryConverter.swift
//  MooyahoApp
//
//  Created by sudo.park on 2022/07/16.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import Remote
import FirebaseFirestore
import Extensions

struct FirebaseQueryConverter {
    
    private let collectionRef: CollectionReference
    init(collectionRef: CollectionReference) {
        self.collectionRef = collectionRef
    }
    
    func convert(_ matchingQuery: MatcingQuery) throws -> Query {
        
        let accumulate: (Query?, MatcingQuery.Condition) throws -> Query = { sum, condition in
            return try self.append(condition, to: sum)
        }
        guard let query = try matchingQuery.conditions.reduce(nil, accumulate)
        else {
            throw RuntimeError("invalid matching query: \(matchingQuery)")
        }
        return query
    }
    
    func convert(_ loadQuery: LoadQuery) throws -> Query {
        let queryWithCondition = try self.convert(loadQuery.matchingQuery)
        let queryWithOrder = loadQuery.orders.reduce(queryWithCondition) {
            self.append($1, to: $0)
        }
        return loadQuery.limit.map { queryWithOrder.limit(to: $0) } ?? queryWithOrder
    }
    
    private func append(_ condition: MatcingQuery.Condition, to query: Query? = nil) throws -> Query {
        
        switch condition.relatation {
        case .equal:
            return query?.whereField(condition.field, isEqualTo: condition.value)
                ?? self.collectionRef.whereField(condition.field, isEqualTo: condition.value)
            
        case .notEqual:
            return query?.whereField(condition.field, isNotEqualTo: condition.value)
                ?? self.collectionRef.whereField(condition.field, isNotEqualTo: condition.value)
            
        case .greaterThan:
            return query?.whereField(condition.field, isGreaterThan: condition.value)
                ?? self.collectionRef.whereField(condition.field, isGreaterThan: condition.value)
            
        case .greaterThanOrEqual:
            return query?.whereField(condition.field, isGreaterThanOrEqualTo: condition.value)
                ?? self.collectionRef.whereField(condition.field, isGreaterThanOrEqualTo: condition.value)
            
        case .lessThan:
            return query?.whereField(condition.field, isLessThan: condition.value)
                ?? self.collectionRef.whereField(condition.field, isLessThan: condition.value)
            
        case .lessThanOrEqual:
            return query?.whereField(condition.field, isLessThanOrEqualTo: condition.value)
                ?? self.collectionRef.whereField(condition.field, isLessThanOrEqualTo: condition.value)
            
        case .in:
            guard let values = condition.value as? [Any]
            else {
                throw RuntimeError("invalid in query for condition -> \(condition)")
            }
            return query?.whereField(condition.field, in: values)
                ?? self.collectionRef.whereField(condition.field, in: values)
            
        case .notIn:
            guard let values = condition.value as? [Any]
            else {
                throw RuntimeError("invalid in query for condition -> \(condition)")
            }
            return query?.whereField(condition.field, notIn: values)
                ?? self.collectionRef.whereField(condition.field, notIn: values)
        }
    }
    
    private func append(_ order: LoadQuery.Order, to query: Query?) -> Query {
        switch order {
        case .asc(let field):
            return query?.order(by: field, descending: false)
                ?? self.collectionRef.order(by: field, descending: false)
            
        case .desc(let field):
            return query?.order(by: field, descending: true)
                ?? self.collectionRef.order(by: field, descending: true)
        }
    }
}
