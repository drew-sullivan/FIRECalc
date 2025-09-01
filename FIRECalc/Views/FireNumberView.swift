//
//  FireNumberView.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import SwiftUI

struct FireNumberView: View {
    @State private var burnRate = "60000"
    @State private var income = "120000"
    @State private var use47Rule = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                CyberpunkTitle(text: "💡 FIRE Number", color: CyberpunkTheme.neonGreen)

                // Inputs
                labeledField("🔥 Annual Spending (Burn Rate)", text: $burnRate, placeholder: "60000")
                labeledField("💵 Pre-Tax Income", text: $income, placeholder: "120000")
                
                Toggle(isOn: $use47Rule) {
                    CyberpunkLabel(text: "Use 4.7% Rule (instead of 4%)", color: CyberpunkTheme.neonGreen)
                }
                .padding(.vertical)
                
                // Results
                if let burn = Double(burnRate) {
                    let fireNum = FIRECalc.fireNumber(burnRate: burn, use47: use47Rule)
                    VStack(alignment: .leading, spacing: 12) {
                        CyberpunkLabel(text: "📊 Required FIRE Number", color: CyberpunkTheme.neonCyan)
                        
                        Text("$\(fireNum, specifier: "%.0f")")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberpunkTheme.neonGreen)
                            .shadow(color: CyberpunkTheme.neonGreen.opacity(0.6), radius: 8)
                        
                        if let inc = Double(income) {
                            let savingsRate = (1 - burn / inc) * 100
                            CyberpunkLabel(
                                text: "Savings Rate: \(String(format: "%.1f", savingsRate))%",
                                color: CyberpunkTheme.neonPurple
                            )
                        }
                    }
                    .cyberpunkPanel()
                }
                
                Spacer()
            }
            .padding()
            .background(CyberpunkTheme.bgGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Helpers
    private func labeledField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            CyberpunkLabel(text: label) // swapped in instead of hardcoded pink
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .cyberpunkField()
        }
    }
}
