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

public struct TextTag {
    
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

public final class TextTagInputField: BaseUIView {
    
    public var placeHolder: String? {
        didSet {
            self.underlyingTextField.placeholder = placeHolder ?? ""
        }
    }
    
    public var isEnabled: Bool {
        get {
            return self.underlyingTextField.textField.isEnabled
        } set {
            self.underlyingTextField.textField.isEnabled = newValue
        }
    }
    
    private let underlyingTextField: UUIDTagInputField = .init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}


extension TextTagInputField: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(underlyingTextField)
        underlyingTextField.autoLayout.activeFill(self)
    }
    
    public func setupStyling() {
        
        self.underlyingTextField.contentInset = .init(top: 4, left: 0, bottom: 4, right: 0)
        self.underlyingTextField.spaceBetweenLines = 10
        self.underlyingTextField.spaceBetweenTags = 10
        self.underlyingTextField.textField.returnKeyType = .continue
    }
}


extension TextTagInputField {
    
    public var didAppendTag: Observable<TextTag> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            self.underlyingTextField.onDidAddTag = { _, tag in
                guard let uuid = tag.context as? String else { return }
                let tag = TextTag(customIdentifier: uuid, text: tag.text)
                observer.onNext(tag)
            }
            return Disposables.create()
        }
    }
    
    public var didRemoveTag: Observable<TextTag> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            self.underlyingTextField.onDidRemoveTag = { _, tag in
                guard let uuid = tag.context as? String else { return }
                let tag = TextTag(customIdentifier: uuid, text: tag.text)
                observer.onNext(tag)
            }
            return Disposables.create()
        }
    }
    
    public func getAllTags() -> [TextTag] {
        return self.underlyingTextField.tags
            .compactMap { wsTag -> TextTag? in
                guard let uuid = wsTag.context as? String else { return nil }
                return TextTag(customIdentifier: uuid, text: wsTag.text)
            }
    }
}
