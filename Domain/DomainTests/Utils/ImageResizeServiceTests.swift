//
//  ImageResizeServiceTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/12/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

import Domain


class ImageResizeServiceTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var service: ImageResizeService!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.service = ImageResizeServiceImple()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.service = nil
    }
    
    private func dummyImage(for size: CGSize) -> UIImage {
        let image: UIImage
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: "rotate.right") ?? UIImage()
        } else {
            image = UIImage()
        }
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: .init(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
}



extension ImageResizeServiceTests {
    
    func testService_resizeWidthSizeOverImage() {
        // given
        let expect = expectation(description: "너비가 맥스 초과인 이미지 리사이즈")
        let size = CGSize(width: 2000, height: 1000)
        let image = self.dummyImage(for: size)
        
        // when
        let resizing = self.service.resize(image)
        let resized = self.waitFirstElement(expect, for: resizing.asObservable())
        
        // then
        XCTAssertEqual(resized?.size.width, 480)
        XCTAssertEqual(resized?.size.height, 240)
    }
    
    func testService_resizeHeightSizeOverImage() {
        // given
        let expect = expectation(description: "높이가 맥스 초과인 이미지 리사이즈")
        let size = CGSize(width: 1000, height: 2000)
        let image = self.dummyImage(for: size)
        
        // when
        let resizing = self.service.resize(image)
        let resized = self.waitFirstElement(expect, for: resizing.asObservable())
        
        // then
        XCTAssertEqual(resized?.size.width, 240)
        XCTAssertEqual(resized?.size.height, 480)
    }
    
    func testService_resizeSizeOverImage() {
        // given
        let expect = expectation(description: "맥스 초과인 이미지 리사이즈")
        let size = CGSize(width: 3000, height: 6000)
        let image = self.dummyImage(for: size)
        
        // when
        let resizing = self.service.resize(image)
        let resized = self.waitFirstElement(expect, for: resizing.asObservable())
        
        // then
        XCTAssertEqual(resized?.size.width, 240)
        XCTAssertEqual(resized?.size.height, 480)
    }
    
    func testService_whenSizeNotOver_doNotResize() {
        // given
        let expect = expectation(description: "리사이즈 할필요없을경우 리사이즈 안함")
        let size = CGSize(width: 200, height: 400)
        let image = self.dummyImage(for: size)
        
        // when
        let resizing = self.service.resize(image)
        let resized = self.waitFirstElement(expect, for: resizing.asObservable())
        
        // then
        XCTAssertEqual(resized?.size.width, 200)
        XCTAssertEqual(resized?.size.height, 400)
    }
}
