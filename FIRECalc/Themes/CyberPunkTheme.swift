//
//  CyberPunkTheme.swift
//  FIRECalc
//
//  Created by Drew Sullivan on 8/31/25.
//

import SwiftUI

struct CyberpunkTheme {
    // MARK: - Palette
    static let bgGradient = LinearGradient(
        colors: [.black, .purple.opacity(0.7), .black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let neonPink = Color.pink
    static let neonCyan = Color.cyan
    static let neonGreen = Color.green
    static let neonPurple = Color.purple
}

// MARK: - Buttons
struct CyberpunkButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [CyberpunkTheme.neonPurple, CyberpunkTheme.neonCyan],
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(color: CyberpunkTheme.neonPurple.opacity(0.7), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - TextFields
struct CyberpunkTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color.black.opacity(0.6))
            .foregroundColor(CyberpunkTheme.neonCyan)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(LinearGradient(colors: [CyberpunkTheme.neonCyan, CyberpunkTheme.neonPurple],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1)
            )
            .shadow(color: CyberpunkTheme.neonPurple.opacity(0.6), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cyberpunkField() -> some View {
        self.modifier(CyberpunkTextField())
    }
}

// MARK: - Panels
struct CyberpunkPanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinearGradient(colors: [.purple, .cyan],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing),
                                    lineWidth: 1)
                    )
            )
            .shadow(color: CyberpunkTheme.neonPink.opacity(0.4), radius: 8)
    }
}

extension View {
    func cyberpunkPanel() -> some View {
        self.modifier(CyberpunkPanel())
    }
}

// MARK: - Titles
struct CyberpunkTitle: View {
    let text: String
    var color: Color = CyberpunkTheme.neonCyan
    
    var body: some View {
        Text(text)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.8), radius: 10)
            .padding(.bottom, 8)
    }
}

struct CyberpunkTabBarStyle {
    static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Neon colors for tab bar items
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(CyberpunkTheme.neonPurple)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(CyberpunkTheme.neonCyan)
        ]
        
        // Apply to all layout styles
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(CyberpunkTheme.neonPurple)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(CyberpunkTheme.neonCyan)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        
        appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance
        
        // Neon glow separator
        appearance.shadowColor = UIColor(CyberpunkTheme.neonPink).withAlphaComponent(0.5)
        
        // Apply globally
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Labels
struct CyberpunkLabel: View {
    let text: String
    var color: Color = CyberpunkTheme.neonGreen // default
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color)
            .shadow(color: color.opacity(0.7), radius: 4)
    }
}
