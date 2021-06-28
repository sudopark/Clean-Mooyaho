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
    
    override func addTag(_ tag: WSTag) {
        let context = tag.context ?? UUID().uuidString as AnyHashable
        let tagElement = WSTag(tag.text, context: context)
        super.addTag(tagElement)
    }
    
    override func addTag(_ tag: String) {
        let tagElement = WSTag(tag, context: UUID().uuidString)
        super.addTag(tagElement)
    }
    
    
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
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
    
    public override func becomeFirstResponder() -> Bool {
        return self.underlyingTextField.becomeFirstResponder()
    }
    
    public func appendTags(_ tagTexts: [String]) {
        self.underlyingTextField.addTags(tagTexts)
    }
}


extension TextTagInputField: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(underlyingTextField)
        underlyingTextField.autoLayout.fill(self)
    }
    
    public func setupStyling() {
        
        self.underlyingTextField.textField.returnKeyType = .default
        self.underlyingTextField.acceptTagOption = .space
        self.underlyingTextField.layoutMargins = UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1)
        self.underlyingTextField.tintColor = .systemBlue.withAlphaComponent(0.95)
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
