//
//  MonteCarloView.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import SwiftUI
import Charts

struct YearlyEntry: Identifiable {
    let id = UUID()
    let year: Int
    let balance: Double
}

struct ContentView: View {
    var body: some View {
        TabView {
            GrowthCalculatorView()
                .tabItem {
                    Label("Growth", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            FireNumberView()
                .tabItem {
                    Label("FIRE Number", systemImage: "dollarsign.circle")
                }
            
            MonteCarloView()
                .tabItem {
                    Label("Monte Carlo", systemImage: "waveform.path.ecg")
                }
            
            HousingScenarioView()
                .tabItem {
                    Label("Housing", systemImage: "house")
                }
        }
    }
}

#Preview { ContentView() }
