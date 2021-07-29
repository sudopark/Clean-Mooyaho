//
//  SelectHoorayPlaceViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - SelectHoorayPlaceViewModel

public struct SuggestPlaceCellViewModel {
    
    public let placeID: String
    public let title: String
    public let position: Coordinate
    public var distance: Meters = 0
    public var distanceText: String = ""
    public var isSelected: Bool = false
    
    public init(snippet: PlaceSnippet) {
        self.placeID = snippet.placeID
        self.title = snippet.title
        self.position = .init(latt: snippet.latt, long: snippet.long)
    }
    
    func distanceCalculated(from userPosition: Coordinate) -> Self {
        var sender = self
        let distanceMeters = sender.position.distance(from: userPosition)
        sender.distance = distanceMeters
        sender.distanceText = distanceMeters.asDistanceText()
        return sender
    }
}

public protocol SelectHoorayPlaceViewModel: AnyObject {

    // interactor
    func suggestPlace(by title: String)
    func refreshUserLocation()
    func toggleUpdateSelected(_ placeID: String)
    func confirmSelectPlace()
    func registerNewPlace()
    
    // presenter
    var moveCamera: Observable<MapCameramovement> { get }
    var cellViewModels: Observable<[SuggestPlaceCellViewModel]> { get }
    var selectedPlaceID: Observable<String> { get }
    var isFinishInputEnabled: Observable<Bool> { get }
    var goNextStepWithForm: Observable<NewHoorayForm> { get }
}


// MARK: - SelectHoorayPlaceViewModelImple

public final class SelectHoorayPlaceViewModelImple: SelectHoorayPlaceViewModel {
    
    private let form: NewHoorayForm
    private let userLocationUsecase: UserLocationUsecase
    private let suggestPlaceUsecase: SuggestPlaceUsecase
    private let router: SelectHoorayPlaceRouting
    
    public init(form: NewHoorayForm,
                userLocationUsecase: UserLocationUsecase,
                suggestPlaceUsecase: SuggestPlaceUsecase,
                router: SelectHoorayPlaceRouting) {
        
        self.form = form
        self.userLocationUsecase = userLocationUsecase
        self.suggestPlaceUsecase = suggestPlaceUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let cameraFocus = BehaviorSubject<MapCameramovement?>(value: nil)
        let selectedPlaceID = BehaviorRelay<String?>(value: nil)
        let cellViewModels = BehaviorRelay<[SuggestPlaceCellViewModel]>(value: [])
        @AutoCompletable var continueNext = PublishSubject<NewHoorayForm>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectHoorayPlaceViewModelImple Interactor

extension SelectHoorayPlaceViewModelImple {
    
    public func suggestPlace(by title: String) {
        guard let center = try? self.subjects.cameraFocus.value()?.center,
              case let .coordinate(coordinate) = center  else { return }
        let lastLocation = LastLocation(lattitude: coordinate.latt, longitude: coordinate.long,
                                        timeStamp: .now())
        let query: SuggestPlaceQuery = title.isEmpty ? .empty : .some(title)
        self.requestSuggestPlace(query, in: lastLocation)
    }
    
    public func refreshUserLocation() {
        self.fetchUserLocationAndUpdateList()
    }
    
    public func toggleUpdateSelected(_ placeID: String) {
        let previousSelectedID = self.subjects.selectedPlaceID.value
        let shouldSelect = previousSelectedID != placeID
        if shouldSelect {
            self.subjects.selectedPlaceID.accept(placeID)
        } else {
            self.subjects.selectedPlaceID.accept(nil)
        }
    }
    
    public func confirmSelectPlace() {
        
        let cellViewModels = self.subjects.cellViewModels.value
        let selectedPlaceID = self.subjects.selectedPlaceID.value
        let selectedPlaceName = cellViewModels.first(where: { $0.placeID == selectedPlaceID })?.title
        
        self.form.placeID = selectedPlaceID
        self.form.placeName = selectedPlaceName
        self.subjects.continueNext.onNext(self.form)
    }
    
    public func registerNewPlace() {

        let userID = self.form.publisherID
        guard let output = self.router.presentNewPlaceRegisterScene(myID: userID) else { return }
        
        let newPlaceRegistered: (Place) -> Void = { [weak self] newPlace in
            guard let self = self else { return }
            let newForm = self.form
            newForm.placeID = newPlace.uid
            newForm.placeName = newPlace.title
            
            self.subjects.continueNext.onNext(newForm)
        }
        
        self.router
            .waitEventAndClosePresented(output.newRegistered)
            .subscribe(onNext: newPlaceRegistered)
            .disposed(by: self.disposeBag)
    }
    
    private var memberID: String {
        return self.form.publisherID
    }
    
    private func requestSuggestPlace(_ query: SuggestPlaceQuery, in lastLocation: LastLocation) {
        let userLocation = UserLocation(userID: self.memberID, lastLocation: lastLocation)
        self.suggestPlaceUsecase.startSuggestPlace(for: query, in: userLocation)
    }
    
}


// MARK: - SelectHoorayPlaceViewModelImple Presenter

extension SelectHoorayPlaceViewModelImple {
    
    public var moveCamera: Observable<MapCameramovement> {
        return self.subjects.cameraFocus.compactMap{ $0 }
    }
    
    public var cellViewModels: Observable<[SuggestPlaceCellViewModel]> {
        
        return self.subjects.cellViewModels.asObservable()
    }
    
    public var selectedPlaceID: Observable<String> {
        return self.subjects.selectedPlaceID.compactMap{ $0 }
    }
    
    public var isFinishInputEnabled: Observable<Bool> {
        return self.subjects.selectedPlaceID
            .map{ $0 != nil }
            .distinctUntilChanged()
    }
    
    public var goNextStepWithForm: Observable<NewHoorayForm> {
        return self.subjects.continueNext.asObservable()
    }
}


// MARK: - internal bind

extension SelectHoorayPlaceViewModelImple {
    
    private typealias CVM = SuggestPlaceCellViewModel
    
    private var suggestedCellViewModels: Observable<[CVM]> {
                
        let cellViewModels = self.suggestPlaceUsecase.placeSuggestResult
            .map{ $0?.places.asCellViewModels() ?? [] }

        let applySelectedInfo: ([CVM], String?) -> [CVM] = { cellViewModels, selectedID in
            return cellViewModels.toggleSelected(selectedID)
        }
        
        let applyDistance: ([CVM], MapCameramovement?) -> [CVM] = { cellViewModels, focus in
            guard let center = focus?.center, case let .coordinate(coordinate) = center else {
                return cellViewModels
            }
            return cellViewModels.map{ $0.distanceCalculated(from: coordinate) }
                .sorted(by: { $0.distance < $1.distance })
        }

        return Observable
            .combineLatest(cellViewModels, self.subjects.selectedPlaceID,
                           resultSelector: applySelectedInfo)
            .withLatestFrom(self.subjects.cameraFocus,
                            resultSelector: applyDistance)
    }
    
    private func internalBinding() {
        
        self.suggestedCellViewModels
            .subscribe(onNext: { [weak self] cellViewModels in
                self?.subjects.cellViewModels.accept(cellViewModels)
            })
            .disposed(by: self.disposeBag)
        
        self.fetchUserLocationAndUpdateList(with: false)
    }
    
    private func fetchUserLocationAndUpdateList(with animation: Bool = true) {
        self.userLocationUsecase.fetchUserLocation()
            .subscribe(onSuccess: { [weak self] location in
                let coordinate = Coordinate(latt: location.lattitude, long: location.longitude)
                let movement = MapCameramovement(center: .coordinate(coordinate), radius: 500, withAnimation: animation)
                self?.subjects.cameraFocus.onNext(movement)
                self?.requestSuggestPlace(.empty, in: location)
            })
            .disposed(by: self.disposeBag)
    }
}


private extension LastLocation {
    
    func asUserLocation(_ memberID: String) -> UserLocation {
        return .init(userID: memberID, lastLocation: self)
    }
}

private extension Array where Element == PlaceSnippet {
    
    func asCellViewModels() -> [SuggestPlaceCellViewModel] {
        return self.map(SuggestPlaceCellViewModel.init(snippet:))
    }
}

private extension Array where Element == SuggestPlaceCellViewModel {
    
    func toggleSelected(_ placeID: String?) -> Array {
        return self.map { cellViewModel in
            var cellViewModel = cellViewModel
            cellViewModel.isSelected = cellViewModel.placeID == placeID
            return cellViewModel
        }
    }
}

