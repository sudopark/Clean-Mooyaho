//
//  AutoLayoutTests.swift
//  CommonPresentingTests
//
//  Created by sudo.park on 2021/05/21.
//

import XCTest

import UnitTestHelpKit

@testable import CommonPresenting


class AutoLayoutTests: BaseTestCase {
    
    private func setupViews() -> (UIView, UIView) {
        let parentView = UIView()
        let subView = UIView()
        parentView.addSubview(subView)
        return (parentView, subView)
    }
    
    func testAutoLayout_buildConstraints() {
        // given
        let (parentView, subView) = self.setupViews()
        
        // when
        let constraints = subView.autoLayout.make {
            $0.leadingAnchor.constraint(equalTo: parentView.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
            $0.topAnchor.constraint(equalTo: parentView.topAnchor)
            $0.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        }
        
        // then
        XCTAssertEqual(subView.translatesAutoresizingMaskIntoConstraints, false)
        XCTAssertEqual(constraints.count, 4)
    }
    
    func testAutoLayout_buildConstraintWithOtherView() {
        // given
        let (parentView, subView) = self.setupViews()
        
        // when
        let constraints = subView.autoLayout.make(with: parentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        // then
        XCTAssertEqual(subView.translatesAutoresizingMaskIntoConstraints, false)
        XCTAssertEqual(constraints.count, 4)
    }
}
