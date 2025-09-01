//
//  HousingScenarioView.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import SwiftUI
import Charts

struct HousingScenarioView: View {
    @State private var startingAmount = "1300000"
    @State private var growthRate = "7"
    @State private var years = "30"
    @State private var monthlyContribution = "10000"
    @State private var fireTarget = "2000000"
    
    @State private var housePrice = "1000000"
    @State private var purchaseYear = "2"
    @State private var mortgageCost = "3000"
    @State private var roommateOffset = "0"
    
    @State private var baseline: [YearlyEntry] = []
    @State private var withHouse: [YearlyEntry] = []
    @State private var fireImpact: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CyberpunkTitle(text: "🏠 Housing Scenario", color: CyberpunkTheme.neonPink)

                    // Inputs
                    Group {
                        labeledField("💰 Starting Portfolio", text: $startingAmount, placeholder: "1300000")
                        labeledField("📈 Growth Rate (%)", text: $growthRate, placeholder: "7")
                        labeledField("⏳ Years", text: $years, placeholder: "30")
                        labeledField("📥 Monthly Contribution", text: $monthlyContribution, placeholder: "10000")
                        labeledField("🔥 FIRE Target", text: $fireTarget, placeholder: "2000000")
                        
                        labeledField("🏠 House Price", text: $housePrice, placeholder: "1000000")
                        labeledField("📅 Purchase Year", text: $purchaseYear, placeholder: "2")
                        labeledField("💸 Mortgage / Rent (per mo)", text: $mortgageCost, placeholder: "3000")
                        labeledField("👥 Roommate Offset", text: $roommateOffset, placeholder: "0")
                    }
                    
                    // Action
                    Button("⚡ Run Scenario", action: runScenario)
                        .buttonStyle(CyberpunkButton())
                    
                    // Chart + results
                    if !baseline.isEmpty {
                        Chart {
                            ForEach(baseline) { entry in
                                LineMark(
                                    x: .value("Year", entry.year),
                                    y: .value("Baseline", entry.balance)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .foregroundStyle(CyberpunkTheme.neonCyan)
                            }
                            
                            ForEach(withHouse) { entry in
                                LineMark(
                                    x: .value("Year", entry.year),
                                    y: .value("With House", entry.balance)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .foregroundStyle(CyberpunkTheme.neonPink)
                            }
                            
                            if let target = Double(fireTarget) {
                                RuleMark(y: .value("Target", target))
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(CyberpunkTheme.neonPurple)
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("FIRE Target: $\(target, specifier: "%.0f")")
                                            .foregroundColor(CyberpunkTheme.neonPurple)
                                            .font(.caption)
                                    }
                            }
                        }
                        .frame(height: 280)
                        .cyberpunkPanel()
                        .padding(.vertical, 4)
                        
                        if let impact = fireImpact {
                            Text(impact)
                                .font(.headline)
                                .foregroundColor(CyberpunkTheme.neonGreen)
                                .padding(.top, 4)
                                .cyberpunkPanel()
                        }
                    }
                }
                .padding()
            }
            .background(CyberpunkTheme.bgGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Logic
    func runScenario() {
        guard let start = Double(startingAmount),
              let rate = Double(growthRate),
              let yrs = Int(years),
              let monthly = Double(monthlyContribution),
              let target = Double(fireTarget),
              let price = Double(housePrice),
              let purchaseYr = Int(purchaseYear),
              let mortgage = Double(mortgageCost),
              let offset = Double(roommateOffset) else { return }
        
        let result = FIRECalc.housingScenario(
            starting: start,
            rate: rate,
            years: yrs,
            monthly: monthly,
            target: target,
            housePrice: price,
            purchaseYear: purchaseYr,
            mortgage: mortgage,
            offset: offset
        )
        baseline = result.baseline
        withHouse = result.withHouse
        fireImpact = result.fireImpact
    }
    
    // MARK: - Helpers
    private func labeledField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            CyberpunkLabel(text: label) // swapped in here
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .cyberpunkField()
        }
    }
}
