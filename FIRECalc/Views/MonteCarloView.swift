//
//  MonteCarloView.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import SwiftUI
import Charts

struct MonteCarloView: View {
    @State private var startingAmount = "10000"
    @State private var growthRate = "7"
    @State private var years = "30"
    @State private var monthlyContribution = "500"
    @State private var fireTarget = "1000000"
    @State private var volatility = "15"
    
    @State private var medianPath: [YearlyEntry] = []
    @State private var lowPath: [YearlyEntry] = []
    @State private var highPath: [YearlyEntry] = []
    @State private var probability: Double? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CyberpunkTitle(text: "🎲 Monte Carlo", color: CyberpunkTheme.neonPurple)

                    // Inputs
                    labeledField("💰 Starting Amount", text: $startingAmount, placeholder: "10000")
                    labeledField("📈 Growth Rate (%)", text: $growthRate, placeholder: "7")
                    labeledField("⏳ Years", text: $years, placeholder: "30")
                    labeledField("📥 Monthly Contribution", text: $monthlyContribution, placeholder: "500")
                    labeledField("🔥 FIRE Target", text: $fireTarget, placeholder: "1000000")
                    labeledField("📊 Volatility (%)", text: $volatility, placeholder: "15")
                    
                    // Action
                    Button("⚡ Run Simulation", action: runSimulation)
                        .buttonStyle(CyberpunkButton())
                    
                    // Chart
                    if !medianPath.isEmpty {
                        Chart {
                            // Shaded band (uncertainty)
                            ForEach(lowPath.indices, id: \.self) { idx in
                                AreaMark(
                                    x: .value("Year", lowPath[idx].year),
                                    yStart: .value("Low", lowPath[idx].balance),
                                    yEnd: .value("High", highPath[idx].balance)
                                )
                                .foregroundStyle(
                                    LinearGradient(colors: [
                                        CyberpunkTheme.neonPurple.opacity(0.2),
                                        CyberpunkTheme.neonCyan.opacity(0.2)
                                    ], startPoint: .top, endPoint: .bottom)
                                )
                            }
                            
                            // Median line
                            ForEach(medianPath) { entry in
                                LineMark(
                                    x: .value("Year", entry.year),
                                    y: .value("Median", entry.balance)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .foregroundStyle(CyberpunkTheme.neonCyan)
                            }
                            
                            // Target line
                            if let target = Double(fireTarget) {
                                RuleMark(y: .value("Target", target))
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(CyberpunkTheme.neonPink)
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("Target: $\(target, specifier: "%.0f")")
                                            .foregroundColor(CyberpunkTheme.neonPink)
                                            .font(.caption)
                                    }
                            }
                        }
                        .frame(height: 300)
                        .cyberpunkPanel()
                        .padding(.vertical, 4)
                        
                        // Probability
                        if let prob = probability {
                            Text("🎲 Probability of reaching FIRE target: \(prob*100, specifier: "%.1f")%")
                                .font(.headline)
                                .foregroundColor(prob >= 0.7
                                                 ? CyberpunkTheme.neonGreen
                                                 : CyberpunkTheme.neonPink)
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
    func runSimulation() {
        guard let start = Double(startingAmount),
              let rate = Double(growthRate),
              let yrs = Int(years),
              let monthly = Double(monthlyContribution),
              let target = Double(fireTarget),
              let stdev = Double(volatility) else { return }
        
        let result = FIRECalc.monteCarlo(
            starting: start,
            rate: rate,
            years: yrs,
            monthly: monthly,
            target: target,
            stdev: stdev
        )
        medianPath = result.median
        lowPath = result.low
        highPath = result.high
        probability = result.probability
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
