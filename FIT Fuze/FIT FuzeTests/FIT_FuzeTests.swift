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

        // Create model data from JSON
        JSONConverter.convert()
    }

    func testStores() {
        // Given
        let store = TrainingPlanStore()
        let plan = TrainingPlan.empty

        // Try
        store.save(plan, id: "0")

        // Verify
        XCTAssert(store.get("0")!.id == plan.id)

        // Clean
        TrainingPlanStore.shared.remove("0")
    }

    func testSearch() {
        // Try
        let plans = TrainingPlanStore.shared.findAll(where: { $0.isFree })

        // Verify
        XCTAssert(plans.count == 2)
    }

    func testWorkoutModification() {
        // Given
        var plan = TrainingPlanStore.shared.get("free001")!
        let workout = plan.workouts.first!
        let item = workout.items.first!

        // Try
        item.executions = [ExecutionDetails(weight: 55, reps: 10, state: .done)]
        TrainingPlanStore.shared.save(plan, id: plan.id)

        // Verify
        plan = TrainingPlanStore.shared.get("free001")!
        XCTAssert(plan.workouts.first!.items.first!.executions.first!.weight == 55)
        XCTAssert(plan.workouts.first!.items.first!.executions.first!.reps == 10)
        XCTAssert(plan.workouts.first!.items.first!.executions.first!.state == .done)
    }

    func testPlansReading() {
        measure {
            _ = TrainingPlanStore.shared.findAll(where: { $0.name.range(of: "a") != nil })
        }
    }

}
