//
//  MonteCarloView.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import SwiftUI
import Charts

struct GrowthCalculatorView: View {
    @State private var startingAmount = "10000"
    @State private var growthRate = "7"
    @State private var years = "30"
    @State private var monthlyContribution = "500"
    @State private var fireTarget = "1000000"
    
    @State private var schedule: [YearlyEntry] = []
    @State private var fireYear: Int? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CyberpunkTitle(text: "🚀 Growth Calculator", color: CyberpunkTheme.neonCyan)

                    // Inputs
                    labeledField("💰 Starting Amount", text: $startingAmount, placeholder: "10000")
                    labeledField("📈 Growth Rate (%)", text: $growthRate, placeholder: "7")
                    labeledField("⏳ Years", text: $years, placeholder: "30")
                    labeledField("📥 Monthly Contribution", text: $monthlyContribution, placeholder: "500")
                    labeledField("🔥 FIRE Target", text: $fireTarget, placeholder: "1000000")
                    
                    // Action
                    Button("⚡ Run Projection", action: calculateSchedule)
                        .buttonStyle(CyberpunkButton())
                        .padding(.top, 8)
                    
                    // Chart
                    if !schedule.isEmpty {
                        Chart {
                            ForEach(schedule) { entry in
                                LineMark(
                                    x: .value("Year", entry.year),
                                    y: .value("Balance", entry.balance)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .foregroundStyle(CyberpunkTheme.neonCyan)
                                
                                if fireYear == entry.year {
                                    PointMark(
                                        x: .value("Year", entry.year),
                                        y: .value("Balance", entry.balance)
                                    )
                                    .foregroundStyle(CyberpunkTheme.neonGreen)
                                    .symbolSize(120)
                                }
                            }
                            if let target = Double(fireTarget) {
                                RuleMark(y: .value("Target", target))
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(CyberpunkTheme.neonPink)
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("FIRE Target: $\(target, specifier: "%.0f")")
                                            .foregroundColor(CyberpunkTheme.neonPink)
                                            .font(.caption)
                                    }
                            }
                        }
                        .frame(height: 300)
                        .cyberpunkPanel()
                    }
                    
                    // Yearly summary
                    if !schedule.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📊 Yearly Summary")
                                .font(.headline)
                                .foregroundColor(CyberpunkTheme.neonCyan)
                            
                            ForEach(schedule) { entry in
                                HStack {
                                    Text("Year \(entry.year)")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("$\(entry.balance, specifier: "%.2f")")
                                        .monospacedDigit()
                                        .foregroundColor(
                                            fireYear == entry.year
                                            ? CyberpunkTheme.neonGreen
                                            : CyberpunkTheme.neonPurple
                                        )
                                }
                                if fireYear == entry.year {
                                    Text("🎉 FIRE reached!")
                                        .font(.subheadline)
                                        .foregroundColor(CyberpunkTheme.neonGreen)
                                }
                                Divider().background(CyberpunkTheme.neonPurple)
                            }
                        }
                        .cyberpunkPanel()
                    }
                }
                .padding()
            }
            .background(CyberpunkTheme.bgGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Logic
    func calculateSchedule() {
        guard let start = Double(startingAmount),
              let rate = Double(growthRate),
              let yrs = Int(years),
              let monthly = Double(monthlyContribution),
              let target = Double(fireTarget) else { return }
        
        let result = FIRECalc.growthSchedule(
            starting: start,
            rate: rate,
            years: yrs,
            monthly: monthly,
            target: target
        )
        schedule = result.schedule
        fireYear = result.fireYear
    }
    
    // MARK: - Helpers
    private func labeledField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            CyberpunkLabel(text: label) // <— instead of hardcoded pink
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .cyberpunkField()
        }
    }
}
