//
//  FIRECalc.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import Foundation

struct FIRECalc {
    // Deterministic growth schedule
    static func growthSchedule(
        starting: Double,
        rate: Double,
        years: Int,
        monthly: Double,
        target: Double
    ) -> (schedule: [YearlyEntry], fireYear: Int?) {
        let monthlyRate = rate / 100 / 12
        var balance = starting
        var yearlySchedule: [YearlyEntry] = []
        var fireYear: Int? = nil
        
        for month in 1...(years * 12) {
            balance += monthly
            balance *= (1 + monthlyRate)
            if month % 12 == 0 {
                let year = month / 12
                yearlySchedule.append(YearlyEntry(year: year, balance: balance))
                if fireYear == nil && balance >= target { fireYear = year }
            }
        }
        return (yearlySchedule, fireYear)
    }
    
    // FIRE number (4% or 4.7%)
    static func fireNumber(burnRate: Double, use47: Bool) -> Double {
        burnRate / (use47 ? 0.047 : 0.04)
    }
    
    // Monte Carlo simulation
    static func monteCarlo(
        starting: Double,
        rate: Double,
        years: Int,
        monthly: Double,
        target: Double,
        stdev: Double,
        trials: Int = 1000
    ) -> (median: [YearlyEntry], low: [YearlyEntry], high: [YearlyEntry], probability: Double) {
        let months = years * 12
        let meanReturn = rate / 100.0
        let stdevReturn = stdev / 100.0
        var allResults: [[Double]] = []
        var successCount = 0
        
        for _ in 0..<trials {
            var balance = starting
            var balances: [Double] = []
            for _ in 0..<months {
                balance += monthly
                // Random normal return (Box-Muller)
                let u1 = Double.random(in: 0..<1)
                let u2 = Double.random(in: 0..<1)
                let randStdNormal = sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)
                let yearlyReturn = meanReturn + stdevReturn * randStdNormal
                let monthlyReturn = yearlyReturn / 12
                balance *= (1 + monthlyReturn)
                balances.append(balance)
            }
            allResults.append(balances)
            if balances.last ?? 0 >= target { successCount += 1 }
        }
        
        var med: [YearlyEntry] = []
        var low: [YearlyEntry] = []
        var high: [YearlyEntry] = []
        for year in 1...years {
            let idx = year * 12 - 1
            let yearValues = allResults.map { $0[idx] }.sorted()
            let mid = yearValues[yearValues.count/2]
            let p10 = yearValues[Int(Double(yearValues.count) * 0.1)]
            let p90 = yearValues[Int(Double(yearValues.count) * 0.9)]
            med.append(YearlyEntry(year: year, balance: mid))
            low.append(YearlyEntry(year: year, balance: p10))
            high.append(YearlyEntry(year: year, balance: p90))
        }
        return (med, low, high, Double(successCount)/Double(trials))
    }
    
    // Housing impact
    static func housingScenario(
        starting: Double,
        rate: Double,
        years: Int,
        monthly: Double,
        target: Double,
        housePrice: Double,
        purchaseYear: Int,
        mortgage: Double,
        offset: Double
    ) -> (baseline: [YearlyEntry], withHouse: [YearlyEntry], fireImpact: String) {
        let monthlyRate = rate / 100 / 12
        
        // Baseline
        var balance = starting
        var baseline: [YearlyEntry] = []
        var baselineFIRE: Int? = nil
        for year in 1...years {
            for _ in 1...12 {
                balance += monthly
                balance *= (1 + monthlyRate)
            }
            baseline.append(YearlyEntry(year: year, balance: balance))
            if baselineFIRE == nil && balance >= target { baselineFIRE = year }
        }
        
        // With house
        balance = starting
        var withHouse: [YearlyEntry] = []
        var withHouseFIRE: Int? = nil
        for year in 1...years {
            for _ in 1...12 {
                let drag = (year >= purchaseYear) ? (mortgage - offset) : 0
                balance += (monthly - drag)
                balance *= (1 + monthlyRate)
            }
            if year == purchaseYear { balance -= housePrice }
            withHouse.append(YearlyEntry(year: year, balance: balance))
            if withHouseFIRE == nil && balance >= target { withHouseFIRE = year }
        }
        
        let fireImpact: String
        if let b = baselineFIRE, let h = withHouseFIRE {
            let diff = h - b
            fireImpact = diff > 0
                ? "🏠 Housing costs delay FIRE by \(diff) years."
                : diff == 0
                    ? "✅ Housing costs do not delay FIRE at all."
                    : "🎉 Housing accelerates FIRE (unexpected)."
        } else {
            fireImpact = "⚠️ Could not reach FIRE target with this scenario."
        }
        
        return (baseline, withHouse, fireImpact)
    }
}
