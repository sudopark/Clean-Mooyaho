//
//  CategoryTextView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/24.
//

import UIKit

import Domain


// MARK: - CategoryTextView

public final class ItemCategoryLabelView: BaseUIView, Presenting {
    
    private let underlyingTextView: UITextView = {
        let container = NSTextContainer()
        let layout = CategoryTextLayoutManager()
        layout.addTextContainer(container)
        
        let storage = NSTextStorage()
        storage.addLayoutManager(layout)
        return UITextView(frame: .zero, textContainer: container)
    }()
    
    public var font: UIFont? {
        get {
            self.underlyingTextView.font
        } set {
            self.underlyingTextView.font = newValue
        }
    }
    
    public func setupLayout() {
        self.addSubview(self.underlyingTextView)
        underlyingTextView.autoLayout.fill(self)
    }
    
    public func setupStyling() {
        self.underlyingTextView.isEditable = false
        self.underlyingTextView.isScrollEnabled = false
    }
}

extension ItemCategoryLabelView {
    
    public func updateCategories(_ categories: [ItemCategory]) {
        let font = self.font ?? self.uiContext.fonts.get(13, weight: .regular)
        let attributedNames = categories.map{ $0.asAttributeString(with: font)}
        
        let seperator: String = "    "
        let totalAttributeText = attributedNames.join(seperator: seperator).asMutable()
        
        let fullRange = NSRange(location: 0, length: totalAttributeText.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 10
        totalAttributeText.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)
        
        self.underlyingTextView.textContainerInset.top = 2
        self.underlyingTextView.textContainerInset.bottom = 4
        self.underlyingTextView.contentInset.left = 5
        self.underlyingTextView.contentInset.right = 5
        self.underlyingTextView.attributedText = totalAttributeText
    }
}


// MARK: - CategoryTextLayoutManager

final class CategoryTextLayoutManager: NSLayoutManager {
    
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let range = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        guard let textStorage = self.textStorage else { return }
        
        let backgroundDrawing: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void = { value, ranhe, _ in
            guard let value = value else {
                super.drawGlyphs(forGlyphRange: range, at: origin)
                return
            }
            let glRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            
            guard let color = (value as? UIColor),
                  let textContainer = self.textContainer(forGlyphAt: glRange.location, effectiveRange: nil),
                  let context = UIGraphicsGetCurrentContext(),
                  let font = self.currentFont(range: range) else {
                return
            }
            
            context.saveGState()
            context.translateBy(x: origin.x, y: origin.y)
            color.setFill()
            
            var rect = self.boundingRect(forGlyphRange: glRange, in: textContainer)
            rect.origin.x = rect.origin.x - 5
            if(rect.origin.y == 0) {
                rect.origin.y = rect.origin.y - 1
            } else {
                rect.origin.y = rect.origin.y - 2
            }
            rect.size.width = rect.size.width + 10
            rect.size.height = font.lineHeight + 4

            let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)
            path.fill()
            context.restoreGState()
            super.drawGlyphs(forGlyphRange: range, at: origin)
        }
        
        textStorage.enumerateAttribute(.roundBackgroundColor,
                                       in: range,
                                       options: .longestEffectiveRangeNotRequired,
                                       using: backgroundDrawing)
    }
    
    private func currentFont(range: NSRange) -> UIFont? {
        guard let attributes = textStorage?.attributes(at: range.location, effectiveRange: nil) else {
            return nil
        }
        return attributes[.font] as? UIFont
    }
}


private extension ItemCategory {
    
    func asAttributeString(with font: UIFont) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: self.name)
        let range = NSRange(location: 0, length: self.name.count)
        attrString.addAttributes([
            .font: font,
            .foregroundColor: UIColor.white,
            .roundBackgroundColor: UIColor.from(hex: self.colorCode) ?? .systemBlue
        ], range: range)
        return attrString
    }
}

private extension Array where Element == NSAttributedString {
    
    func join(seperator: String) -> NSAttributedString {
        let seed = NSMutableAttributedString(string: "")
        return self.reduce(into: seed) { acc, element in
            let seperator = acc.length == 0 ? "" : seperator
            acc.append(NSAttributedString(string: seperator))
            acc.append(element)
        }
    }
}

private extension NSAttributedString.Key {
    
    static var roundBackgroundColor: NSAttributedString.Key {
        return NSAttributedString.Key(rawValue: "RoundedBackgroundColorAttribute")
    }
}

private extension NSAttributedString {
    
    func asMutable() -> NSMutableAttributedString {
        return .init(attributedString: self)
    }
}
