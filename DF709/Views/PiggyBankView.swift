//
//  PiggyBankView.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct PiggyBankView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateCoins = false
    @State private var animatePiggyBank = false
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                Spacer()
                
                // Main piggy bank display
                piggyBankView
                
                Spacer()
                
                // Stats section
                statsView
                
                Spacer()
                
                // Back button
                backButton
            }
            
            // Golden particles animation
            if showParticles {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(ColorTheme.primaryGold.opacity(0.4))
                        .frame(width: 6 + CGFloat(index))
                        .offset(
                            x: CGFloat(index * 30 - 100),
                            y: CGFloat(index * 40 - 150)
                        )
                        .scaleEffect(showParticles ? 1.0 : 0.0)
                        .animation(
                            Animation.easeInOut(duration: 2 + Double(index) * 0.3)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: showParticles
                        )
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.navigateTo(.mainMenu)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Menu")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .foregroundColor(ColorTheme.primaryGold)
            }
            
            Spacer()
            
            Text("Achievements")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for symmetry
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("Menu")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var piggyBankView: some View {
        VStack(spacing: 30) {
            // Achievement trophy with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(ColorTheme.goldGlowGradient)
                    .frame(width: 200, height: 200)
                    .opacity(animatePiggyBank ? 0.8 : 0.3)
                    .scaleEffect(animatePiggyBank ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animatePiggyBank)
                
                // Trophy container
                ZStack {
                    Circle()
                        .fill(ColorTheme.goldGradient)
                        .frame(width: 150, height: 150)
                        .shadow(color: ColorTheme.primaryGold.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.black)
                }
                .scaleEffect(animatePiggyBank ? 1.0 : 0.8)
                .animation(.spring(response: 1.0, dampingFraction: 0.6), value: animatePiggyBank)
                
                // Floating stars
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(ColorTheme.primaryGold)
                        .offset(
                            x: cos(Double(index) * .pi * 2 / 5) * 80,
                            y: sin(Double(index) * .pi * 2 / 5) * 80
                        )
                        .scaleEffect(animateCoins ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.6)
                                .delay(Double(index) * 0.1),
                            value: animateCoins
                        )
                }
            }
            
            // Points count display
            VStack(spacing: 10) {
                Text("\(appState.userProfile.totalPoints)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.primaryGold)
                    .glow(color: ColorTheme.primaryGold, radius: 10)
                    .scaleEffect(animateCoins ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: animateCoins)
                
                Text("Total Points")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateCoins ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.7), value: animateCoins)
            }
        }
    }
    
    private var statsView: some View {
        VStack(spacing: 20) {
            Text("Your Achievements")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .opacity(animateCoins ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(0.9), value: animateCoins)
            
            HStack(spacing: 30) {
                StatCard(
                    icon: "star.fill",
                    title: "Current Level",
                    value: "\(appState.userProfile.currentLevel)",
                    color: ColorTheme.primaryGold,
                    delay: 1.0
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Completed",
                    value: "\(appState.userProfile.completedLevels.count)",
                    color: ColorTheme.turquoise,
                    delay: 1.1
                )
                
                StatCard(
                    icon: "star.fill",
                    title: "Total Points",
                    value: "\(appState.userProfile.totalPoints)",
                    color: ColorTheme.secondaryRed,
                    delay: 1.2
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var backButton: some View {
        Button("Continue Playing") {
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.navigateTo(.mainMenu)
            }
        }
        .buttonStyle(GoldenButtonStyle())
        .opacity(animateCoins ? 1.0 : 0.0)
        .offset(y: animateCoins ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(1.3), value: animateCoins)
        .padding(.bottom, 30)
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animatePiggyBank = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateCoins = true
            }
        }
        
        showParticles = true
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let delay: Double
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(ColorTheme.mediumGrey)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
                    .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorTheme.darkGrey.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        .scaleEffect(animate ? 1.0 : 0.8)
        .opacity(animate ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay), value: animate)
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    PiggyBankView()
        .environmentObject(AppState())
}
