//
//  TagInputField.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import UIKit

import RxSwift
import RxCocoa

// MARK: - Tag

public struct TextTag {
    
    public let identifier: String
    public let text: String
    
    public init(customIdentifier: String, text: String) {
        self.identifier = customIdentifier
        self.text = text
    }
}


//final class UUIDTagInputField: WSTagsField {
//
//    override func addTag(_ tag: WSTag) {
//        let context = tag.context ?? UUID().uuidString as AnyHashable
//        let tagElement = WSTag(tag.text, context: context)
//        super.addTag(tagElement)
//    }
//
//    override func addTag(_ tag: String) {
//        let tagElement = WSTag(tag, context: UUID().uuidString)
//        super.addTag(tagElement)
//    }
//
//
//    override func becomeFirstResponder() -> Bool {
//        return self.textField.becomeFirstResponder()
//    }
//}

public final class TextTagInputField: BaseUIView {
    
    public var placeHolder: String? {
        didSet {
            self.underlyingTextField.placeholder = placeHolder ?? ""
        }
    }
    
    public var isEnabled: Bool {
        get {
            return self.underlyingTextField.isEnabled
        } set {
            self.underlyingTextField.isEnabled = newValue
        }
    }
    
    private let underlyingTextField: UITextField = .init()
    
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
        
    }
}


extension TextTagInputField: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(underlyingTextField)
        underlyingTextField.autoLayout.fill(self)
    }
    
    public func setupStyling() {
        
//        self.underlyingTextField.textField.returnKeyType = .default
//        self.underlyingTextField.acceptTagOption = .space
        self.underlyingTextField.layoutMargins = UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1)
        self.underlyingTextField.tintColor = .systemBlue.withAlphaComponent(0.95)
    }
}


extension TextTagInputField {
    
    public var didAppendTag: Observable<TextTag> {
        return .empty()
        
    }
    
    public var didRemoveTag: Observable<TextTag> {
        return .empty()
    }
    
    public func getAllTags() -> [TextTag] {
        return []
    }
}
