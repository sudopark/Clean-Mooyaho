//
//  WordTokensView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/05.
//

import UIKit

import RxSwift


// MARK: - WorkTokens

public struct WordToken {
    
    public let word: String
    public let color: UIColor
    public let identifier: String
    public var isHighlighted = false
    
    public init(word: String, color: UIColor? = nil,
                identifier: String? = nil, isHighlighted: Bool = false) {
        self.word = word
        self.color = color ?? .systemBlue
        self.identifier = identifier ?? word
        self.isHighlighted = isHighlighted
    }
}


// MARK: - WordTokensView

fileprivate enum Metric {
    
    static let labelCotentXPadding: CGFloat = 8
}

extension Attribute {
    
    static let textTokenFont: UIFont = .systemFont(ofSize: 16)
}


// MARK: - LeadingFlowLayout

public class WordsLeadingFlowLayout: UICollectionViewFlowLayout {
    
    private let cellHeight: CGFloat
    private var contentHeight: CGFloat = 0
    private var wordItems: [String] = []
    
    public init(cellHeight: CGFloat) {
        self.cellHeight = cellHeight
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var maxCellWidth: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - insets.left - insets.right
    }
    
    private var contentWidth: CGFloat {
        return self.maxCellWidth
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: maxCellWidth, height: self.contentHeight)
    }
    
    private var cached: [UICollectionViewLayoutAttributes] = []
}

extension WordsLeadingFlowLayout {
    
    public func updateItems(_ words: [String]) {
        self.wordItems = words
    }
    
    public override func prepare() {
        
        self.cached.removeAll()
        
        guard let collectionView = collectionView else { return }
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        let (itemSpacing, lineSpacing) = (CGFloat(6), CGFloat(8))
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        (0..<itemCount).forEach { index in
            
            let remainXSpacing = self.contentWidth - xOffset
            
            let word = self.wordItems[safe: index] ?? ""
            let expectedWidth = word.expectWidth(font: Attribute.textTokenFont)
                + Metric.labelCotentXPadding * 2

            let frame: CGRect
            if expectedWidth < remainXSpacing {
                let cellWidth = expectedWidth
                frame = .init(origin: .init(x: xOffset, y: yOffset),
                              size: .init(width: cellWidth, height: cellHeight))
                xOffset += cellWidth + itemSpacing
            } else {
                let cellWidth = min(expectedWidth, maxCellWidth)
                yOffset += cellHeight + lineSpacing
                frame = .init(origin: .init(x: 0, y: yOffset),
                              size: .init(width: cellWidth, height: cellHeight))
                xOffset = cellWidth + itemSpacing
            }
            
            let indexPath = IndexPath(row: index, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = frame
            cached.append(attribute)
            
        }
        self.contentHeight = self.cached.last?.frame.maxY ?? 0
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleLayoutAttributes = self.cached.filter { $0.frame.intersects(rect) }
        return visibleLayoutAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cached[safe: indexPath.item]
    }
}


// MARK: - MaxHeightCollectionView

public class MaxHeightCollectionView: UICollectionView {
    
    var maxHeight: CGFloat?
    
    public override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    public override var intrinsicContentSize: CGSize {
        let maxHeight = self.maxHeight
        
        let size = self.collectionViewLayout.collectionViewContentSize
        let height = maxHeight.map{ min(size.height, $0) } ?? size.height
        return .init(width: size.width, height: height)
    }
}

final class WordTokenCell: UICollectionViewCell {
    
    let backColorView = UIView()
    let wordLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupLayout()
        self.setupStyling()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupCell(_ token: WordToken) {
        self.wordLabel.text = token.word
        self.backColorView.backgroundColor = token.color
        self.backColorView.alpha = token.isHighlighted ? 1.0 : 0.5
        self.wordLabel.textAlignment = .center
        self.wordLabel.lineBreakMode = .byTruncatingTail
    }
}

extension WordTokenCell: Presenting {
    
    func setupLayout() {
        
        self.contentView.addSubview(backColorView)
        backColorView.autoLayout.fill(self.contentView)
        
        self.contentView.addSubview(wordLabel)
        wordLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: Metric.labelCotentXPadding)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -Metric.labelCotentXPadding)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
    }
    
    func setupStyling() {
        
        backColorView.layer.cornerRadius = 6
        backColorView.clipsToBounds = true
        
        wordLabel.font = Attribute.textTokenFont
        wordLabel.textColor = UIColor.white
    }
}

public final class WordTokensView: BaseUIView {
    
    private var tokens: [WordToken] = []
    
    private let maxHeight: CGFloat?
    public var collectionView: MaxHeightCollectionView!
    
    public init(maxHeight: CGFloat? = nil) {
        self.maxHeight = maxHeight
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func updateTokens(_ tokens: [WordToken]) {
        self.tokens = tokens
        (self.collectionView.collectionViewLayout as? WordsLeadingFlowLayout)?
            .updateItems(tokens.map{ $0.word })
        self.collectionView.reloadData()
    }
}


extension WordTokensView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.tokens.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let token = self.tokens[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkTokenCell", for: indexPath) as! WordTokenCell
        cell.setupCell(token)
        return cell
    }
}


extension WordTokensView: Presenting {
    
    private func makeLayout() -> WordsLeadingFlowLayout {
        let layout = WordsLeadingFlowLayout(cellHeight: 28)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }
    
    public func setupLayout() {
        
        let layout = self.makeLayout()
        self.collectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView.maxHeight = self.maxHeight
        
        self.addSubview(collectionView)
        collectionView.autoLayout.fill(self)
    }
    
    public func setupStyling() {
        
        self.collectionView.register(WordTokenCell.self, forCellWithReuseIdentifier: "WorkTokenCell")
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}
