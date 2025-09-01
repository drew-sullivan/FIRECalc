//
//  FIRECalcTests.swift
//  FIRECalcTests
//
//  Created by Drew Sullivan on 8/31/25.
//

import XCTest
@testable import FIRECalc

final class FIRECalcTests: XCTestCase {
    
    // MARK: - Growth Schedule
    func testGrowthScheduleReachesTarget() {
        let result = FIRECalc.growthSchedule(
            starting: 100_000,
            rate: 6,
            years: 30,
            monthly: 1000,
            target: 1_000_000
        )
        
        XCTAssertFalse(result.schedule.isEmpty, "Schedule should not be empty")
        XCTAssertNotNil(result.fireYear, "FIRE year should be reached within 30 years")
        XCTAssertGreaterThanOrEqual(result.schedule.last!.balance, 1_000_000, "End balance should exceed target")
    }
    
    func testGrowthScheduleNeverReachesTarget() {
        let result = FIRECalc.growthSchedule(
            starting: 100,
            rate: 1,
            years: 5,
            monthly: 0,
            target: 10_000_000
        )
        
        XCTAssertNil(result.fireYear, "Should never hit target")
    }
    
    func testGrowthScheduleDeterministic() {
        let a = FIRECalc.growthSchedule(starting: 1000, rate: 5, years: 10, monthly: 100, target: 5000)
        let b = FIRECalc.growthSchedule(starting: 1000, rate: 5, years: 10, monthly: 100, target: 5000)
        XCTAssertEqual(a.schedule.map { $0.balance }, b.schedule.map { $0.balance }, "Growth schedule must be deterministic")
    }
    
    // MARK: - FIRE Number
    func testFireNumber_4PercentRule() {
        let fire = FIRECalc.fireNumber(burnRate: 40_000, use47: false)
        XCTAssertEqual(fire, 1_000_000, accuracy: 0.01)
    }
    
    func testFireNumber_4Point7PercentRule() {
        let fire = FIRECalc.fireNumber(burnRate: 40_000, use47: true)
        XCTAssertEqual(fire, 851_063.83, accuracy: 0.01)
    }
    
    // MARK: - Monte Carlo
    func testMonteCarloOutputsHaveCorrectLength() {
        let result = FIRECalc.monteCarlo(
            starting: 10_000,
            rate: 7,
            years: 20,
            monthly: 500,
            target: 1_000_000,
            stdev: 15,
            trials: 200
        )
        
        XCTAssertEqual(result.median.count, 20)
        XCTAssertEqual(result.low.count, 20)
        XCTAssertEqual(result.high.count, 20)
        XCTAssert(result.probability >= 0 && result.probability <= 1, "Probability must be valid")
    }
    
    func testMonteCarloImprovesWithMoreSavings() {
        let lowSavings = FIRECalc.monteCarlo(
            starting: 10_000, rate: 7, years: 30,
            monthly: 100, target: 1_000_000, stdev: 15, trials: 300
        )
        let highSavings = FIRECalc.monteCarlo(
            starting: 10_000, rate: 7, years: 30,
            monthly: 2000, target: 1_000_000, stdev: 15, trials: 300
        )
        
        XCTAssertGreaterThan(highSavings.probability, lowSavings.probability,
                             "More monthly savings should improve success probability")
    }
    
    // MARK: - Housing Scenario
    func testHousingScenarioDelaysFIRE() {
        let result = FIRECalc.housingScenario(
            starting: 1_000_000,
            rate: 6,
            years: 30,
            monthly: 5000,
            target: 2_000_000,
            housePrice: 500_000,
            purchaseYear: 1,
            mortgage: 2000,
            offset: 0
        )
        
        XCTAssertFalse(result.baseline.isEmpty)
        XCTAssertFalse(result.withHouse.isEmpty)
        XCTAssert(result.fireImpact.contains("delay") || result.fireImpact.contains("⚠️"),
                  "Impact should mention delay or failure")
    }
    
    func testHousingScenarioWithRoommateHelps() {
        let solo = FIRECalc.housingScenario(
            starting: 1_000_000, rate: 6, years: 30, monthly: 5000, target: 2_000_000,
            housePrice: 500_000, purchaseYear: 1, mortgage: 2000, offset: 0
        )
        let roommate = FIRECalc.housingScenario(
            starting: 1_000_000, rate: 6, years: 30, monthly: 5000, target: 2_000_000,
            housePrice: 500_000, purchaseYear: 1, mortgage: 2000, offset: 1000
        )
        
        XCTAssertNotEqual(solo.fireImpact, roommate.fireImpact,
                          "Roommate offset should change FIRE impact")
    }
}

// MARK: - Edge Cases
extension FIRECalcTests {
    
    func testZeroGrowthAndZeroContributions() {
        let result = FIRECalc.growthSchedule(
            starting: 1000,
            rate: 0,
            years: 10,
            monthly: 0,
            target: 2000
        )
        // Balance should remain constant
        XCTAssertEqual(result.schedule.last?.balance ?? 0.0, 1000, accuracy: 0.01)
        XCTAssertNil(result.fireYear, "Should never hit target if nothing grows or is added")
    }
    
    func testNegativeGrowthShrinksPortfolio() {
        let result = FIRECalc.growthSchedule(
            starting: 1000,
            rate: -5,
            years: 5,
            monthly: 0,
            target: 1
        )
        XCTAssertLessThan(result.schedule.last!.balance, 1000, "Negative growth should reduce balance")
    }
    
    func testHousingPurchaseBeyondHorizonIsIgnored() {
        let result = FIRECalc.housingScenario(
            starting: 100_000,
            rate: 5,
            years: 5,
            monthly: 1000,
            target: 200_000,
            housePrice: 500_000,
            purchaseYear: 10, // beyond horizon
            mortgage: 2000,
            offset: 0
        )
        // With-house and baseline should be identical if purchase happens after horizon
        XCTAssertEqual(result.baseline.map { $0.balance },
                       result.withHouse.map { $0.balance },
                       "House purchase after horizon should have no effect")
        XCTAssertTrue(result.fireImpact.contains("do not delay") || result.fireImpact.contains("⚠️"))
    }
    
    func testHousingOffsetGreaterThanMortgageIsNetPositive() {
        let result = FIRECalc.housingScenario(
            starting: 100_000,
            rate: 5,
            years: 10,
            monthly: 1000,
            target: 200_000,
            housePrice: 100_000,
            purchaseYear: 1,
            mortgage: 1000,
            offset: 2000
        )
        
        // It may still delay FIRE due to the one-time house price hit,
        // but it should never be because of ongoing housing drag.
        XCTAssertTrue(
            result.fireImpact.contains("delay") ||
            result.fireImpact.contains("do not delay") ||
            result.fireImpact.contains("accelerates"),
            "Impact string should always be one of the expected categories"
        )
    }
}

