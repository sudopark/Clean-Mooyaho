//
//  ReadCollectionTtileHeaderView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/16.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics


// MARK: - ReadCollectionTtileHeaderView

public typealias ReadCollectionTtileHeaderView = BaseTableViewHeaderView


// MARK: - ReadCollectionSectionHeaderView

open class ReadCollectionSectionHeaderView: BaseTableViewSectionHeaderFooterView, Presenting {
    
    private let titleLabel = UILabel()
    
    open override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    public func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    open func setupLayout() {
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 4)
        }
    }
    
    open func setupStyling() {
        _ = self
            |> \.backgroundColor .~ self.uiContext.colors.appBackground
            |> \.tintColor .~ self.uiContext.colors.appBackground
        _ = self.titleLabel |> self.uiContext.decorating.listSectionTitle(_:)
    }
}


extension ReadCollectionItemSectionType {
    
    public func makeSectionHeaderIfPossible() -> ReadCollectionSectionHeaderView? {
        guard self != .attribute else { return nil }
        let header = ReadCollectionSectionHeaderView()
        header.setupTitle(self.rawValue)
        return header
    }
}



public protocol ShrinkableTtileHeaderViewSupporting: BaseViewController {
    
    var titleHeaderView: BaseTableViewHeaderView { get }
    var titleHeaderViewRelatedScrollView: UIScrollView { get }
}

extension ShrinkableTtileHeaderViewSupporting {
    
    private var isTitleHaderViewShowing: Observable<Bool> {
        
        let checkScrollAmount: (CGPoint) -> Bool? = { [weak self] point in
            guard let self = self, self.titleHeaderView.frame.height > 0 else { return nil }
            return point.y <= self.titleHeaderView.frame.height
        }
        return self.titleHeaderViewRelatedScrollView.rx.contentOffset
            .compactMap(checkScrollAmount)
            .distinctUntilChanged()
    }
    
    public func bindUpdateTitleheaderViewByScroll(with titleSource: Observable<String>) {
        
        let selectTitle: (String, Bool) -> String? = { title, isHeaderShowing in
            return isHeaderShowing ? nil : title
        }
        Observable
            .combineLatest(titleSource,
                           self.isTitleHaderViewShowing,
                           resultSelector: selectTitle)
            .startWith(nil)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                self?.title = title
            })
            .disposed(by: self.disposeBag)
        
        titleSource
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.titleHeaderView.setupTitle(title)
            })
            .disposed(by: self.disposeBag)
    }
}
