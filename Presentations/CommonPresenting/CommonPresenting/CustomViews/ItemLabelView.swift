//
//  CategoryTextView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/24.
//

import UIKit

import Domain


// MARK: - CategoryTextView

public final class ItemLabelView: BaseUIView {
    
    private struct LabelElement {
        
        let attrText: NSAttributedString
        let backgroundColor: UIColor
        
        init(text: String, font: UIFont, backgroundColor: UIColor?, textColor: UIColor) {
            self.backgroundColor = backgroundColor ?? .clear
            self.attrText = NSAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: textColor
            ])
        }
    }
    
    private var elements: [LabelElement] = []
    private var elementRects: [CGRect] = []
    private var maxHeight: CGFloat?
    
    private var underlyingFont: UIFont?
    
    public override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor ?? self.uiContext.colors.appBackground
        }
        set {
            super.backgroundColor = newValue
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidate()
    }
    
    public override var intrinsicContentSize: CGSize {
        self.elementRects.removeAll()
        let maxWidth = self.bounds.width
        guard maxWidth > 0 else { return .zero }
        
        var (contentSize, origin) = (CGSize.zero, CGPoint.zero)
        let edge = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        let spacing: CGFloat = 6
        
        let maxSize = CGSize(width: maxWidth, height: self.maxHeight ?? CGFloat.greatestFiniteMagnitude)
        for element in self.elements {
            if let maxHeight = maxHeight, origin.y > maxHeight {
                continue
            }
            let rect = element.attrText
                .boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil)
            let (width, height) = (rect.width + edge.left + edge.right,
                                   rect.height + edge.top + edge.bottom)
            if origin.x + width > maxWidth {
                origin.x = 0; origin.y += height + spacing
                contentSize.height = self.maxHeight.map { min(origin.y, $0) } ?? origin.y
            }
            let itemRect = CGRect(origin: origin, size: CGSize(width: width, height: height))
            self.elementRects.append(itemRect)
            
            origin.x += (width + spacing)
            contentSize.width = max(contentSize.width, origin.x + width)
            contentSize.height = self.maxHeight.map { min(origin.y + height, $0) } ?? origin.y + height
        }
        return contentSize
    }
    
    public override func draw(_ rect: CGRect) {
        
        func draw(element: LabelElement, elementRect: CGRect) {
            element.backgroundColor.setFill()
            element.backgroundColor.setStroke()
            let path = UIBezierPath(roundedRect: elementRect, cornerRadius: 5)
            path.fill()
            
            let point = CGPoint(x: elementRect.origin.x + 4, y: elementRect.origin.y + 2)
            element.attrText.draw(at: point)
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(self.backgroundColor?.cgColor ?? self.uiContext.colors.appBackground.cgColor)
        
        for (index, element) in self.elements.enumerated() {
            guard let elementRect = self.elementRects[safe: index] else { continue }
            draw(element: element, elementRect: elementRect)
        }
        
        UIGraphicsEndImageContext()
    }
    
    private func invalidate() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsDisplay()
    }
}


// MARK: - update attribute

extension ItemLabelView {
    
    public var font: UIFont {
        get {
            return self.underlyingFont ?? self.uiContext.fonts.get(13, weight: .regular)
        } set {
            self.underlyingFont = newValue
        }
    }
    
    public func limitHeight(max: CGFloat) {
        self.maxHeight = max
        self.invalidate()
    }
}

// MARK: - update labels

extension ItemLabelView {
    
    public func updateCategories(_ categories: [ItemCategory]) {
        
        let elements = categories.map {
            LabelElement(
                text: $0.name, font: self.font,
                backgroundColor: UIColor.from(hex: $0.colorCode),
                textColor: .white
            )
        }
        self.updateElements(elements)
    }
    
    public func setupPriority(_ priority: ReadPriority) {
        let elements = [
            LabelElement(
                text: "\(priority.emoji) \(priority.description)",
                font: self.font,
                backgroundColor: self.uiContext.colors.blueGray,
                textColor: .white
            )
        ]
        self.updateElements(elements)
    }
    
    public func setupRemind(_ time: TimeStamp) {
        let elements = [
            LabelElement(
                text: time.remindTimeText(),
                font: self.font,
                backgroundColor: .clear,
                textColor: self.uiContext.colors.text
            )
        ]
        self.updateElements(elements)
    }
    
    public func setupRemindWithIcon(_ time: TimeStamp) {
        let elements = [
            LabelElement(
                text: "⛳️ \(time.remindTimeText())",
                font: self.font,
                backgroundColor: UIColor.tertiarySystemGroupedBackground,
                textColor: UIColor.label
            )
        ]
        self.updateElements(elements)
    }
    
    private func updateElements(_ elements: [LabelElement]) {
        self.elements = elements
        self.invalidate()
    }
}
