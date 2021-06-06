//
//  TagInputField.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import UIKit

import RxSwift
import RxCocoa
import WSTagsField

// MARK: - Tag

public struct Tag {
    
    public let identifier: String
    public let text: String
    
    public init(customIdentifier: String, text: String) {
        self.identifier = customIdentifier
        self.text = text
    }
}


final class UUIDTagInputField: WSTagsField {
    
    override func addTag(_ tag: String) {
        let tagElement = WSTag(tag, context: UUID().uuidString)
        super.addTag(tagElement)
    }
}

public final class TagInputField: BaseUIView {
    
    private let underlyingTextField: UUIDTagInputField = .init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}


extension TagInputField: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(underlyingTextField)
        underlyingTextField.autoLayout.activeFill(self)
    }
    
    public func setupStyling() {
        
        self.underlyingTextField.spaceBetweenLines = 8
        self.underlyingTextField.spaceBetweenTags = 6
        self.underlyingTextField.textField.returnKeyType = .continue
    }
}


extension TagInputField {
    
    public var didAppendTag: Observable<Tag> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            self.underlyingTextField.onDidAddTag = { _, tag in
                guard let uuid = tag.context as? String else { return }
                let tag = Tag(customIdentifier: uuid, text: tag.text)
                observer.onNext(tag)
            }
            return Disposables.create()
        }
    }
    
    public var didRemoveTag: Observable<Tag> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            self.underlyingTextField.onDidRemoveTag = { _, tag in
                guard let uuid = tag.context as? String else { return }
                let tag = Tag(customIdentifier: uuid, text: tag.text)
                observer.onNext(tag)
            }
            return Disposables.create()
        }
    }
    
    public func getAllTags() -> [Tag] {
        return self.underlyingTextField.tags
            .compactMap { wsTag -> Tag? in
                guard let uuid = wsTag.context as? String else { return nil }
                return Tag(customIdentifier: uuid, text: wsTag.text)
            }
    }
}
