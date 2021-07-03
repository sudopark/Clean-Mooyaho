//
//  ManuallyResigterPlaceViewModel.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - ManuallyResigterPlaceViewModel

public protocol ManuallyResigterPlaceViewModel: AnyObject {

    // interactor
    func showup()
    func requestEnterText()
    func requestSelectPosition()
    func requestEnterCategoryTag()
    func savePendingInput()
    func requestRegister()
    
    // presenter
    var placeTitle: Observable<String> { get }
    var placeAddress: Observable<String> { get }
    var placeLocation: Observable<Coordinate> { get }
    var selectedTags: Observable<[PlaceCategoryTag]> { get }
    var isRegistable: Observable<Bool> { get }
    var isRegistering: Observable<Bool> { get }
    var newPlace: Observable<Place> { get }
}


// MARK: - ManuallyResigterPlaceViewModelImple

public final class ManuallyResigterPlaceViewModelImple: ManuallyResigterPlaceViewModel {
    
    private let userID: String
    private let userLocationUsecase: UserLocationUsecase
    private let registerUsecase: RegisterNewPlaceUsecase
    private let router: ManuallyResigterPlaceRouting
    
    private var locationMarkInput: LocationMarkSceneInput!
    
    public init(userID: String,
                userLocationUsecase: UserLocationUsecase,
                registerUsecase: RegisterNewPlaceUsecase,
                router: ManuallyResigterPlaceRouting) {
        self.userID = userID
        self.userLocationUsecase = userLocationUsecase
        self.registerUsecase = registerUsecase
        self.router = router
        
        self.loadPreviousInput()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let pendingForm = BehaviorRelay<NewPlaceForm?>(value: nil)
        let isRegistering = BehaviorRelay<Bool>(value: false)
        let newPlace = PublishSubject<Place>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - ManuallyResigterPlaceViewModelImple Interactor

extension ManuallyResigterPlaceViewModelImple {
    
    public func showup() {
        guard self.locationMarkInput == nil else { return }
        self.locationMarkInput = self.router.addSmallMapView()
    }
    
    public func requestEnterText() {
        
        let title = self.subjects.pendingForm.value?.title
        
        let mode = TextInputMode(isSingleLine: true, title: "Place name",
                                 placeHolder: "Enter a place name...",
                                 startWith: title,
                                 maxCharCount: 100,
                                 shouldEnterSomething: true,
                                 defaultHeight: 120)
        
        guard let result = self.router.openPlaceTitleInputScene(mode) else { return }
        result.enteredText.take(1)
            .subscribe(onNext: { [weak self] text in
                self?.updateForm{ $0.title = text }
            })
            .disposed(by: self.disposeBag)
    }
    
    public func requestSelectPosition() {
        
        let form = self.subjects.pendingForm.value
        let info: PreviousSelectedLocationInfo? = {
            guard let position = form?.coordinate, let addres = form?.address else { return nil }
            return .init(latt: position.latt, long: position.long, address: addres)
        }()
        guard let result = self.router.openLocationSelectScene(info) else { return }
        result.selectedLocation.take(1)
            .subscribe(onNext: { [weak self] location in
                self?.updateForm{
                    $0.address = location.placeMark?.address ?? ""
                    $0.coordinate = .init(latt: location.lattitude, long: location.longitude)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    public func requestEnterCategoryTag() {
        let total = self.registerUsecase.placeCategoryTags()
        let tags = self.subjects.pendingForm.value?.categoryTags ?? []
        guard let result = self.router.openTagSelectScene(tags, total: total) else { return }
        result.selectedTags.take(1)
            .subscribe(onNext: { [weak self] tags in
                self?.updateForm {
                    $0.categoryTags = tags
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    public func savePendingInput() {
        
        guard let form = self.subjects.pendingForm.value else { return }
        self.registerUsecase.finishInputPlaceInfo(form)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestRegister() {
        
        guard self.subjects.isRegistering.value == false,
              let form = self.subjects.pendingForm.value else { return }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isRegistering.accept(false)
            self?.router.alertError(error)
        }
        
        let closeAndEmitEvent: (Place) -> Void = { [weak self] place in
            self?.subjects.isRegistering.accept(false)
            self?.router.closeScene(animated: true) {
                self?.subjects.newPlace.onNext(place)
            }
        }
        
        self.subjects.isRegistering.accept(true)
        self.registerUsecase.uploadNewPlace(form)
            .subscribe(onSuccess: closeAndEmitEvent, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func updateForm(_ mutating: (NewPlaceForm) -> Void) {
        let form = self.subjects.pendingForm.value ?? .init(reporterID: self.userID, infoProvider: .userDefine)
        mutating(form)
        self.subjects.pendingForm.accept(form)
    }
    
    private func loadPreviousInput() {
        
        let fetchCurrentPosition = self.userLocationUsecase.fetchUserLocation()
        
        let thenLoadPreviousInput: (LastLocation) -> Maybe<NewPlaceForm?> = { [weak self] location in
            guard let self = self else { return .empty() }
            let coordinate: Coordinate = .init(latt: location.lattitude, long: location.longitude)
            return self.registerUsecase.loadRegisterPendingNewPlaceForm(withIn: coordinate)
        }
        
        let updateForm: (NewPlaceForm) -> Void = { [weak self] previousForm in
            self?.subjects.pendingForm.accept(previousForm)
        }
        
        fetchCurrentPosition
            .flatMap(thenLoadPreviousInput)
            .compactMap{ $0 }
            .subscribe(onSuccess: updateForm)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - ManuallyResigterPlaceViewModelImple Presenter

extension ManuallyResigterPlaceViewModelImple {
    
    public var placeTitle: Observable<String> {
        return self.subjects.pendingForm.compactMap{ $0 }
            .map{ $0.title }
            .distinctUntilChanged()
    }
    
    public var placeAddress: Observable<String> {
        return self.subjects.pendingForm.compactMap{ $0 }
            .map{ $0.address }
            .distinctUntilChanged()
    }
    
    public var placeLocation: Observable<Coordinate> {
        return self.subjects.pendingForm.compactMap{ $0 }
            .compactMap{ $0.coordinate }
            .distinctUntilChanged()
    }
    
    public var selectedTags: Observable<[PlaceCategoryTag]> {
        return self.subjects.pendingForm.compactMap{ $0 }
            .map{ $0.categoryTags }
            .distinctUntilChanged()
    }
    
    public var isRegistable: Observable<Bool> {
        return self.subjects.pendingForm.compactMap{ $0 }
            .map {
                $0.title.isNotEmpty && $0.address.isNotEmpty
            }
            .distinctUntilChanged()
    }
    
    public var isRegistering: Observable<Bool> {
        return self.subjects.isRegistering
            .distinctUntilChanged()
    }
    
    public var newPlace: Observable<Place> {
        return self.subjects.newPlace.asObservable()
    }
}
