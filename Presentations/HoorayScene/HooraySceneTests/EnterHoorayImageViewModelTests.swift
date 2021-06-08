//
//  EnterHoorayImageViewModelTests.swift
//  HooraySceneTests
//
//  Created by sudo.park on 2021/06/07.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import StubUsecases

@testable import HoorayScene


class EnterHoorayImageViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var form: NewHoorayForm!
    var stubService: StubImagePickPermissionCheckService!
    var spyRouter: SpyRouter!
    var viewModel: EnterHoorayImageViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubService = .init()
        self.spyRouter = .init()
        self.form = .init(publisherID: "some")
        self.viewModel = .init(form: self.form,
                               imagePickPermissionCheckService: self.stubService,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubService = nil
        self.spyRouter = nil
        self.form = nil
        self.viewModel = nil
    }
}


extension EnterHoorayImageViewModelTests {
    
    func testViewmodel_whenTryToSelectImage_checkPermission() {
        // given
        let expect = expectation(description: "이미지 선택시에 권한 검사해서 없으면 에레 알림")
        
        self.stubService.register(key: "preparePermission") {
            return Maybe<Void>.error(ImagePickPermissionDenied())
        }
        
        self.spyRouter.called(key: "alertForConfirm") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.selectImage()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenSelectImageAndHasPermission_askPickingMode() {
        // given
        let expect = expectation(description: "권한있고 이미지 선택 시도시에 선택모드 질의")
        
        self.stubService.register(key: "preparePermission") {
            return Maybe<Void>.just()
        }
        
        self.spyRouter.called(key: "alertActionSheet") { args in
            guard let actionCount = args as? Int, actionCount == 3 else { return }
            expect.fulfill()
        }
        
        // when
        self.viewModel.selectImage()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenPreviousImageSelcted_showEditImageAction() {
        // given
        let expect = expectation(description: "이미 이미지가 선책된 상태로 진입한경우 이미지 편집버튼 노출")
        self.stubService.register(key: "preparePermission") {
            return Maybe<Void>.just()
        }
        self.spyRouter.called(key: "alertActionSheet") { args in
            guard let actionCount = args as? Int, actionCount == 4 else { return }
            expect.fulfill()
        }
        
        // when
        self.form.imagePath = "previous"
        self.viewModel = .init(form: self.form,
                               imagePickPermissionCheckService: self.stubService, router: self.spyRouter)
        self.viewModel.selectImage()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_deSelectImage() {
        // given
        let expect = expectation(description: "선택한 이미지 선택 해제")
        expect.expectedFulfillmentCount = 2
        self.form.imagePath = "previous"
        self.viewModel = .init(form: self.form,
                               imagePickPermissionCheckService: self.stubService, router: self.spyRouter)
        
        // when
        let images = self.waitElements(expect, for: self.viewModel.selectedImagePath) {
            self.viewModel.deselect()
        }
        
        // then
        XCTAssertNotNil(images.first ?? nil)
        XCTAssertNil(images.last ?? nil)
    }
    
    func testViewModel_whenDeSelectImage_deleteTempFile() {
        // given
        let expect = expectation(description: "선택한 이미지 선택 해제시에 임시파일 삭제")
        let spyFileService = SpyFileService()
        self.form.imagePath = "previous"
        self.viewModel = .init(form: self.form,
                               imagePickPermissionCheckService: self.stubService,
                               fileHandleService: spyFileService,
                               router: self.spyRouter)
        
        spyFileService.called(key: "deletFile") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.deselect()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension EnterHoorayImageViewModelTests {
    
    func testViewModel_whenAfterPickImage_updateSelectedImage() {
        // given
        let expect = expectation(description: "사진 선택이후에 선책이미지 업데이트")
        
        self.stubService.register(key: "preparePermission") { Maybe<Void>.just() }
        let stubImagePickPresenter = StubImagePickPresenter()
        self.spyRouter.register(type: ImagePickerScenePresenter.self, key: "presentImagePicker") {
            stubImagePickPresenter
        }
        self.spyRouter.stubConfiemOpenPicker = true
        
        // when
        let imagePath = self.waitFirstElement(expect, for: self.viewModel.selectedImagePath.compactMap{ $0 }) {
            self.viewModel.selectImage()
            stubImagePickPresenter.stubSelectedImage.onNext("some")
        }
        
        // then
        XCTAssertNotNil(imagePath)
    }
    
    func testViewModel_goNextInputStage() {
        // given
        let expect = expectation(description: "다음 입력화면으로 이동")
        
        self.form.imagePath = "previous"
        self.viewModel = .init(form: self.form,
                               imagePickPermissionCheckService: self.stubService, router: self.spyRouter)
        
        // when
        let form = self.waitFirstElement(expect, for: self.viewModel.goNextStepWithForm) {
            self.viewModel.goNextInputStage()
        }
        
        // then
        XCTAssertNotNil(form)
    }
}


extension EnterHoorayImageViewModelTests {
    
    class StubImagePickPermissionCheckService: ImagePickPermissionCheckService, Stubbable {
        
        func preparePermission(for level: ImagePickAccessLevel) -> Maybe<Void> {
            return self.resolve(key: "preparePermission") ?? .empty()
        }
    }
    
    class SpyRouter: EnterHoorayImageRouting, Stubbable {
        
        func askImagePickingModel(_ form: ActionSheetForm) {
            self.verify(key: "askImagePickingModel")
        }
        
        func presentEditScene(selectImage image: UIImage, edited: (UIImage) -> Void) {
            
        }
        
        func presentImagePicker(isCamera: Bool) -> ImagePickerScenePresenter? {
            return self.resolve(key: "presentImagePicker")
        }

        func alertForConfirm(_ form: AlertForm) {
            self.verify(key: "alertForConfirm")
        }
        
        var stubConfiemOpenPicker: Bool = false
        func alertActionSheet(_ form: ActionSheetForm) {
            self.verify(key: "alertActionSheet", with: form.actions.count)
            if stubConfiemOpenPicker {
                let action = form.actions.first(where: { $0.text == "Take a picture".localized })
                action?.selected?()
            }
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            completed?()
        }
    }
    
    class StubImagePickPresenter: ImagePickerScenePresenter {
        
        let stubSelectedImage = PublishSubject<String>()
        var selectedImagePath: Observable<String> {
            return self.stubSelectedImage.asObservable()
        }
        
        var selectImageError: Observable<Error> {
            return .empty()
        }
    }
    
    class SpyFileService: FileHandleService, Stubbable {
        
        func deletFile(_ path: FilePath) -> Maybe<Void> {
            self.verify(key: "deletFile")
            return .empty()
        }
    }
}
