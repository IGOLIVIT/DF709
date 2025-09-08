//
//  MainMenuView.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateTitle = false
    @State private var animateButtons = false
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App title with golden glow
                    VStack(spacing: 8) {
                        Text("Golden Flow")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.primaryGold)
                            .glow(color: ColorTheme.primaryGold, radius: 15)
                            .scaleEffect(animateTitle ? 1.0 : 0.8)
                            .opacity(animateTitle ? 1.0 : 0.0)
                            .animation(.spring(response: 1.0, dampingFraction: 0.6), value: animateTitle)
                        
                        Text("Premium Puzzle Experience")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ColorTheme.mediumGrey)
                            .opacity(animateTitle ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.8).delay(0.3), value: animateTitle)
                    }
                    
                    // Player stats
                    HStack(spacing: 30) {
                        StatView(
                            icon: "star.fill",
                            value: "\(appState.userProfile.currentLevel)",
                            label: "Level"
                        )
                        
                        StatView(
                            icon: "star.circle.fill",
                            value: "\(appState.userProfile.totalPoints)",
                            label: "Points"
                        )
                        
                        StatView(
                            icon: "checkmark.circle.fill",
                            value: "\(appState.userProfile.completedLevels.count)",
                            label: "Completed"
                        )
                    }
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: animateTitle)
                    
                    Spacer()
                }
                
                // Menu buttons section
                VStack(spacing: 25) {
                    MenuButton(
                        title: "Play Game",
                        subtitle: "Start your golden adventure",
                        icon: "play.fill",
                        color: ColorTheme.primaryGold,
                        delay: 0.0
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.startGame(level: appState.userProfile.currentLevel)
                        }
                    }
                    
                    MenuButton(
                        title: "Achievements",
                        subtitle: "View your progress and rewards",
                        icon: "trophy.fill",
                        color: ColorTheme.turquoise,
                        delay: 0.1
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.navigateTo(.piggyBank)
                        }
                    }
                    
                    MenuButton(
                        title: "Settings",
                        subtitle: "Customize your experience",
                        icon: "gearshape.fill",
                        color: ColorTheme.secondaryRed,
                        delay: 0.2
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.navigateTo(.settings)
                        }
                    }
                }
                .opacity(animateButtons ? 1.0 : 0.0)
                .offset(y: animateButtons ? 0 : 50)
                .animation(.easeOut(duration: 1.0).delay(0.7), value: animateButtons)
                
                Spacer()
                
                // Footer
                Text("Crafted with ❤️ for puzzle lovers")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(ColorTheme.mediumGrey.opacity(0.7))
                    .opacity(animateButtons ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(1.2), value: animateButtons)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateTitle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                animateButtons = true
            }
        }
        
        showParticles = true
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ColorTheme.primaryGold)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(ColorTheme.mediumGrey)
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let delay: Double
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var animate = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(ColorTheme.mediumGrey)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ColorTheme.mediumGrey)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorTheme.darkGrey.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .padding(.horizontal, 30)
        .opacity(animate ? 1.0 : 0.0)
        .offset(x: animate ? 0 : 100)
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(delay), value: animate)
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppState())
}
