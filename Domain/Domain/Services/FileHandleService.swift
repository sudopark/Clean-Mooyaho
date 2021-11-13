//
//  FileHandleService.swift
//  Domain
//
//  Created by sudo.park on 2021/06/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public enum FilePath {
    
    case raw(_ value: String)
    case temp(_ fileName: String)
    
    public var fullPath: String {
        switch self {
        case let .raw(value):
            return value
                .relativePath()
            
        case let .temp(fileName):
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(fileName)
                .path
                .relativePath()
        }
    }
    
    public var absolutePath: String {
        switch self {
        case let .raw(path): return path
        case let .temp(fileName):
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(fileName)
                .standardizedFileURL
                .absoluteString
        }
    }
}


public protocol FileHandleService {
    
    func checkIsExists(_ path: FilePath) -> Bool
    
    func copy(source: FilePath, to: FilePath) -> Maybe<Void>
    
    func write(data: Data, to: FilePath) -> Maybe<Void>
    
    func deletFile(_ path: FilePath) -> Maybe<Void>
}

extension FileHandleService {
    
    public func checkIsExists(_ path: FilePath) -> Bool { return false }
    
    public func copy(source: FilePath, to: FilePath) -> Maybe<Void> { return .empty() }
    
    public func write(data: Data, to: FilePath) -> Maybe<Void> { return .empty() }
    
    public func deletFile(_ path: FilePath) -> Maybe<Void> { return .empty() }
}


extension FileManager: FileHandleService {
    
    public func checkIsExists(_ path: FilePath) -> Bool {
        let fullPath = path.fullPath
        return self.fileExists(atPath: fullPath)
    }
    
    public func copy(source: FilePath, to: FilePath) -> Maybe<Void> {
        
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            do {
                try? self.removeItem(atPath: to.fullPath)
                try self.copyItem(atPath: source.fullPath, toPath: to.fullPath)
                callback(.success(()))
            } catch let error {
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    public func write(data: Data, to: FilePath) -> Maybe<Void> {
        return Maybe.create { callback in
            do {
                let fileURL = URL(fileURLWithPath: to.fullPath)
                try data.write(to: fileURL)
                callback(.success(()))
            } catch let error {
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    public func deletFile(_ path: FilePath) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            do {
                try self.removeItem(atPath: path.fullPath)
                callback(.success(()))
            } catch let error {
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
}

private extension String {
    
    func relativePath() -> String {
        return URL(string: self)?.relativePath ?? self
    }
}
