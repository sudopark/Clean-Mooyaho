//
//  ColorSelectViewModel.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/10/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain


public struct ColorCellViewMdoel: Equatable {
    public let hextCode: String
    public var isSelected: Bool = false
}

// MARK: - ColorSelectViewModel

public protocol ColorSelectViewModel: AnyObject, Sendable {

    // interactor
    func selectColor(_ code: String)
    func confirmSelect()
    
    // presenter
    var cellViewModels: Observable<[ColorCellViewMdoel]> { get }
}


// MARK: - ColorSelectViewModelImple

public final class ColorSelectViewModelImple: ColorSelectViewModel, @unchecked Sendable {
    
    private let router: ColorSelectRouting
    private weak var listener: ColorSelectSceneListenable?
    
    public init(startWithSelect: String?,
                colorSources: [String],
                router: ColorSelectRouting,
                listener: ColorSelectSceneListenable?) {
        self.router = router
        self.listener = listener
        
        self.subjects.colorCodes.onNext(colorSources)
        self.subjects.selectColor.accept(startWithSelect)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let colorCodes = BehaviorSubject<[String]>(value: [])
        let selectColor = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - ColorSelectViewModelImple Interactor

extension ColorSelectViewModelImple {
    
    public func selectColor(_ code: String) {
        self.subjects.selectColor.accept(code)
    }
    
    public func confirmSelect() {
        
        let selected = self.subjects.selectColor.value
        self.router.closeScene(animated: true) { [weak self] in
            guard let selected = selected else { return }
            self?.listener?.colorSelect(didSeelctColor: selected)
        }
    }
}


// MARK: - ColorSelectViewModelImple Presenter

extension ColorSelectViewModelImple {
    
    public var cellViewModels: Observable<[ColorCellViewMdoel]> {
        
        let asCellViewModels: ([String], String?) -> [ColorCellViewMdoel]
        asCellViewModels = { codes, selected in
            return codes.map { .init(hextCode: $0, isSelected: $0 == selected) }
        }
        return Observable
            .combineLatest(self.subjects.colorCodes,
                           self.subjects.selectColor,
                           resultSelector: asCellViewModels)
            .distinctUntilChanged()
    }
}
