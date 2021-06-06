//
//  MakeHoorayViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - MakeHoorayViewModel

public protocol MakeHoorayViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - MakeHoorayViewModelImple

enum SelectPlace {
    case alreadyExist(_ placeID: String)
    case registerNeeds(_ newPlaceForm: NewPlaceForm)
}

public final class MakeHoorayViewModelImple: MakeHoorayViewModel {
    
    private let memberUsecase: MemberUsecase
    private let userLocationUsecase: UserLocationUsecase
    private let hoorayPublishUsecase: HoorayPublisherUsecase
    private let router: MakeHoorayRouting
    
    public init(memberUsecase: MemberUsecase,
                userLocationUsecase: UserLocationUsecase,
                hoorayPublishUsecase: HoorayPublisherUsecase,
                router: MakeHoorayRouting) {
        self.memberUsecase = memberUsecase
        self.userLocationUsecase = userLocationUsecase
        self.hoorayPublishUsecase = hoorayPublishUsecase
        self.router = router
    
        self.internalBind()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let currentMember = BehaviorRelay<Member?>(value: nil)
        let selectedHoorayKeyword = BehaviorRelay<String?>(value: nil)
        let pendingInputMessage = BehaviorRelay<String>(value: "")
        let pendingInputTags = BehaviorRelay<[String]>(value: [])
        let pendingSelectPlace = BehaviorRelay<SelectPlace?>(value: nil)
        let isPublishing = BehaviorRelay<Bool>(value: false)
        let newHooray = PublishSubject<Hooray>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - MakeHoorayViewModelImple Interactor

extension MakeHoorayViewModelImple {
 
    public func requestChangeMemnerProfileImage() {
        _ = self.router.openEditProfileScene()
    }
    
    public func enterHooray(message: String) {
        self.subjects.pendingInputMessage.accept(message)
    }
    
    public func requestSelectPlace() {
        self.router.presentPlaceSelectScene()
    }
    
    func placeSelected(_ selectedPlace: SelectPlace) {
        self.subjects.pendingSelectPlace.accept(selectedPlace)
    }
    
    public func requestPublishNewHooray(with tags: [String]) {
        
        let isPlaceSelected = self.subjects.pendingSelectPlace.value != nil
        guard isPlaceSelected else {
            self.routeToAskSelectPlace(tags)
            return
        }
        self.uploadNewHooray(tags)
    }
    
    private func uploadNewHooray(_ tags: [String]) {
        
        guard self.subjects.isPublishing.value == false,
              let myID = self.subjects.currentMember.value?.uid,
              let keyword = self.subjects.selectedHoorayKeyword.value else { return }
        let message = self.subjects.pendingInputMessage.value
        
        let thenLoadCurrentLocation: () -> Maybe<LastLocation> = { [weak self] in
            return self?.userLocationUsecase.fetchUserLocation() ?? .empty()
        }
        
        let thenPrepareForm: (LastLocation) throws -> NewHoorayForm = { location in
            let coordinate = Coordinate(latt: location.lattitude, long: location.longitude)
            guard let form = NewHoorayFormBuilder(base: .init(publisherID: myID))
                    .hoorayKeyword(keyword).message(message).tags(tags)
                    .timeStamp(TimeInterval.now()).location(coordinate)
                    .build() else {
                throw ApplicationErrors.invalid
            }
            return form
        }
        
        let finallyRequestPublish: (NewHoorayForm) -> Maybe<Hooray> = { [weak self] form in
            return self?.hoorayPublishUsecase.publish(newHooray: form, withNewPlace: nil) ?? .empty()
        }
        
        let hoorayPublished: (Hooray) -> Void = { [weak self] hooray in
            self?.router.closeScene(animated: true, completed: nil)
            self?.subjects.newHooray.onNext(hooray)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isPublishing.accept(false)
            guard let applicationError = error as? ApplicationErrors,
                  case let .shouldWaitPublishHooray(until) = applicationError else {
                self?.router.alertError(error)
                return
            }
            self?.router.alertShouldWaitPublishNewHooray(until)
        }
        
        self.subjects.isPublishing.accept(true)
        self.hoorayPublishUsecase.isAvailToPublish()
            .flatMap(thenLoadCurrentLocation)
            .map(thenPrepareForm)
            .flatMap(finallyRequestPublish)
            .subscribe(onSuccess: hoorayPublished, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MakeHoorayViewModelImple Presenter

extension MakeHoorayViewModelImple {
    
    public var memberProfileImage: Observable<ImageSource> {
        return self.subjects.currentMember.compactMap{ $0 }
            .map{ $0.icon ?? Member.memberDefaultEmoji }
    }
    
    public var hoorayKeyword: Observable<String> {
        return self.subjects.selectedHoorayKeyword.compactMap{ $0 }
    }
    
    public var isPublishable: Observable<Bool> {
        return self.subjects.pendingInputMessage
            .map{ $0.isNotEmpty }
            .distinctUntilChanged()
    }
    
    public var isPublishing: Observable<Bool> {
        return self.subjects.isPublishing.distinctUntilChanged()
    }
    
    public var publishedNewHooray: Observable<Hooray> {
        return self.subjects.newHooray.asObservable()
    }
}


// internal bindinds

private extension MakeHoorayViewModelImple {
    
    func internalBind() {
        
        let member = self.memberUsecase.fetchCurrentMember()
        self.subjects.currentMember.accept(member)
        
        // TODO: 정책 정해야함
        let defaultKeyword = "Hooray".localized
        self.subjects.selectedHoorayKeyword.accept(defaultKeyword)
    }
    
    func routeToAskSelectPlace(_ tags: [String]) {
        
        let cancel: () -> Void = { [weak self] in
            self?.uploadNewHooray(tags)
        }
        
        let confirmed: () -> Void = { [weak self] in
            logger.todoImplement("should move to place select scene")
        }
        guard let form = AlertBuilder(base: .init())
                .message("[TBD] message")
                .canceled(cancel)
                .confirmed(confirmed)
                .build() else { return }
        
        self.router.askSelectPlaceInfo(form)
    }
}
