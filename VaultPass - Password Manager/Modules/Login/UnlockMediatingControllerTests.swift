//
//  UnlockMediatingControllerTests.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/21/23.
//


import XCTest
@testable import VaultPass___Password_Manager

final class UnlockMediatingControllerTests: XCTestCase {
    
    override class func setUp() {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testIBOutletsNotNil() {
        // given
        let controller = UnlockMediatingController.loadFromNibMain()
        // when
        controller.loadViewIfNeeded()
        // then
        XCTAssertNotNil(controller.unlockButton)
        XCTAssertNotNil(controller.unlockDetailLabel)
        XCTAssertNotNil(controller.termsAndConditionsBtn)
        XCTAssertNotNil(controller.privacyPolicyBtn)
    }
}