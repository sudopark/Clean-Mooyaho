//
//  EditReadPriorityViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public struct ReadPriorityCellViewMdoel {
    
    public let rawValue: Int
    public let descriptionText: String
    public var isSelected: Bool = false
    
    public init(priority: ReadPriority) {
        self.rawValue = priority.rawValue
        self.descriptionText = priority.longDescription
    }
}

// MARK: - EditReadPriorityViewModel

public protocol EditReadPriorityViewModel: AnyObject {
    
    // interactor
    func showPriorities()
    func selectPriority(_ rawValue: Int)
    func confirmSelect()
    
    // presenter
    var cellViewModels: Observable<[ReadPriorityCellViewMdoel]> { get }
    var isProcessing: Observable<Bool> { get }
}


// MARK: - EditReadPriorityViewModelImple

public class BaseEditReadPriorityViewModelImple: EditReadPriorityViewModel {
    
    let router: EditReadPriorityRouting
    weak var listener: EditReadPrioritySceneListenable?
    
    public init(router: EditReadPriorityRouting,
                listener: EditReadPrioritySceneListenable?) {
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    final class Subjects {
        let priorities = BehaviorRelay<[ReadPriority]>(value: [])
        let selectedPriority = BehaviorRelay<ReadPriority?>(value: nil)
        let isProcessing = BehaviorRelay<Bool>(value: false)
    }
    
    var startWithSelect: ReadPriority? { nil }
    
    let subjects = Subjects()
    let disposeBag = DisposeBag()
    
    // override
    public func confirmSelect() { }
}


// MARK: - EditReadPriorityViewModelImple Interactor

extension BaseEditReadPriorityViewModelImple {
    
    public func showPriorities() {
        let priorities = ReadPriority.allCases.sorted(by: { $0.rawValue > $1.rawValue })
        self.subjects.priorities.accept(priorities)
    }
    
    public func selectPriority(_ rawValue: Int) {
        
        let oldOne = self.subjects.selectedPriority.value ?? self.startWithSelect
        guard let newOne = ReadPriority(rawValue: rawValue), newOne != oldOne else {
            return
        }
        self.subjects.selectedPriority.accept(newOne)
    }
}


// MARK: - EditReadPriorityViewModelImple Presenter

extension BaseEditReadPriorityViewModelImple {
 
    public var cellViewModels: Observable<[ReadPriorityCellViewMdoel]> {
        
        let startWith = self.startWithSelect
        
        let asCellViewModels: ([ReadPriority], ReadPriority?) -> [ReadPriorityCellViewMdoel]
        asCellViewModels = { priorities, selected in
            let selected = selected ?? startWith
            return priorities.asCellViewModels(selected)
        }
        return Observable.combineLatest(
            self.subjects.priorities.filter { $0.isNotEmpty },
            self.subjects.selectedPriority,
            resultSelector: asCellViewModels
        )
    }
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing
            .distinctUntilChanged()
    }
}

private extension ReadPriority {
    
    var longDescription: String {
        let text: String = {
            switch self {
            case .afterAWhile: return "As soon as possible".localized
            case .onTheWaytoWork: return "On the way home".localized
            case .beforeGoToBed: return "Before go to bed.".localized
            case .today: return "I'm going to read it today".localized
            case .thisWeek: return "I think I'll read it this week!".localized
            case .someDay: return "Someday~".localized
            case .beforeDying: return "Will I do it before I die?".localized
            }
        }()
        return "\(self.emoji)   \(text)"
    }
}

private extension Array where Element == ReadPriority {
    
    func asCellViewModels(_ selected: ReadPriority?) -> [ReadPriorityCellViewMdoel] {
        return self.map {
            return ReadPriorityCellViewMdoel(priority: $0)
                |> \.isSelected .~ (selected?.rawValue == $0.rawValue)
        }
    }
}
