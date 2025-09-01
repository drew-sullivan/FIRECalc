# 🔥 FIRECalc

iOS app for exploring **FIRE** scenarios

---

## ✨ Features
- 📈 Growth calculator  
- 💡 FIRE number using 4% or 4.7% rule
- 🎲 Basic Monte Carlo simulator with success probabilities  
- 🏠 Housing scenario modeling (mortgage, roommates, etc.)

## 📸 Screenshots

<p align="center">
  <img src="docs/growth.png" alt="Growth Calculator" width="220"/>
  <img src="docs/fire.png" alt="FIRE Number" width="220"/>
</p>

<p align="center">
  <img src="docs/housing.png" alt="Housing Scenario" width="220"/>
  <img src="docs/monte_carlo.png" alt="Monte Carlo" width="220"/>
</p>

---

## 🛠️ Setup Guide

### 1. Install Xcode
- Download **Xcode** from the App Store
- It’s big (~10GB), so give it time
- Open Xcode once to let it finish installing command-line tools

### 2. Clone the Repo
- $ git clone git@github.com:drew-sullivan/FIRECalc.git
- cd FIRECalc

### 3. Open the Project in Xcode
- open FIRECalc.xcodeproj within FIRECalc
- Xcode will launch and load the project

### 4. Run the App in the iOS Simulator (CMD + R)
- In Xcode’s top center toolbar, select:
    - Device: any iPhone simulator (e.g. iPhone 16 Pro)
    - Scheme: FIRECalc
- Press ▶ Run (or use shortcut Cmd+R).
- The app will build and launch in the simulator.

### 5. Modify & Test
- SwiftUI views live in Views/
- Core math lives in FIRECalc.swift
- Run unit tests: CMD + U
