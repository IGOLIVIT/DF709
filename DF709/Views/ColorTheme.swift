//
//  ColorTheme.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct ColorTheme {
    // Background colors
    static let background = Color(hex: "0D0D0D")
    static let darkGrey = Color(hex: "1E1E1E")
    static let mediumGrey = Color(hex: "444444")
    
    // Accent colors
    static let primaryGold = Color(hex: "FFD700")
    static let secondaryRed = Color(hex: "B22222")
    static let turquoise = Color(hex: "00CED1")
    
    // Gradient colors
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGlowGradient = RadialGradient(
        colors: [Color(hex: "FFD700").opacity(0.8), Color(hex: "FFD700").opacity(0.3), Color.clear],
        center: .center,
        startRadius: 10,
        endRadius: 50
    )
    
    static let waterGradient = LinearGradient(
        colors: [Color(hex: "00CED1"), Color(hex: "4682B4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Button Styles
struct GoldenButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isEnabled ? ColorTheme.goldGradient : LinearGradient(colors: [ColorTheme.mediumGrey], startPoint: .top, endPoint: .bottom))
                    .shadow(color: isEnabled ? ColorTheme.primaryGold.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(ColorTheme.primaryGold)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorTheme.darkGrey.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ColorTheme.primaryGold, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Custom View Modifiers
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func glow(color: Color = ColorTheme.primaryGold, radius: CGFloat = 10) -> some View {
        self.modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ColorTheme.background
                    .ignoresSafeArea()
                
                // Animated golden particles
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(ColorTheme.primaryGold.opacity(0.08))
                        .frame(width: 30 + CGFloat(index * 5))
                        .position(
                            x: CGFloat(50 + index * 40).truncatingRemainder(dividingBy: geometry.size.width),
                            y: CGFloat(100 + index * 80).truncatingRemainder(dividingBy: geometry.size.height)
                        )
                        .scaleEffect(animateGradient ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 3 + Double(index))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5),
                            value: animateGradient
                        )
                }
            }
        }
        .onAppear {
            animateGradient = true
        }
    }
}
