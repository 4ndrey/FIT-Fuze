//
//  FIT_FuzeTests.swift
//  FIT FuzeTests
//
//  Created by IVAN CHERNOV on 25.05.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import XCTest
@testable import FIT_Fuze

class FIT_FuzeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStores() {
        // Given
        let store = TrainingPlanStore()
        let plan = TrainingPlan.empty

        // Try
        store.save(plan, id: "0")

        // Verify
        XCTAssert(store.get("0")!.id == plan.id)
    }

}
