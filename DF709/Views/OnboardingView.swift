//
//  OnboardingView.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateButton = false
    @State private var showGlow = false
    
    let pages = [
        OnboardingPage(
            title: "Golden Flow",
            subtitle: "Connect the golden pipes and create the perfect flow",
            systemImage: "drop.fill",
            description: "Master the art of pipe connection in this luxurious puzzle experience"
        ),
        OnboardingPage(
            title: "Solve Puzzles",
            subtitle: "Challenge your mind with increasingly complex levels",
            systemImage: "puzzlepiece.fill",
            description: "Each level brings new challenges and greater rewards"
        ),
        OnboardingPage(
            title: "Earn Rewards",
            subtitle: "Collect points and unlock achievements",
            systemImage: "star.circle.fill",
            description: "Your success is rewarded with points and trophies"
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Top section with animated content
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App icon with glow effect
                    ZStack {
                        Circle()
                            .fill(ColorTheme.goldGradient)
                            .frame(width: 120, height: 120)
                            .glow(color: ColorTheme.primaryGold, radius: showGlow ? 30 : 10)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: showGlow)
                        
                        Image(systemName: pages[currentPage].systemImage)
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .scaleEffect(animateTitle ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateTitle)
                    
                    // Title
                    Text(pages[currentPage].title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.primaryGold)
                        .multilineTextAlignment(.center)
                        .opacity(animateTitle ? 1.0 : 0.0)
                        .offset(y: animateTitle ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateTitle)
                    
                    // Subtitle
                    Text(pages[currentPage].subtitle)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(animateSubtitle ? 1.0 : 0.0)
                        .offset(y: animateSubtitle ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateSubtitle)
                    
                    // Description
                    Text(pages[currentPage].description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(ColorTheme.mediumGrey)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(animateSubtitle ? 1.0 : 0.0)
                        .offset(y: animateSubtitle ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateSubtitle)
                    
                    Spacer()
                }
                
                // Bottom section with navigation
                VStack(spacing: 30) {
                    // Page indicator
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? ColorTheme.primaryGold : ColorTheme.mediumGrey)
                                .frame(width: 12, height: 12)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .opacity(animateButton ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: animateButton)
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("Previous") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                    resetAnimations()
                                    startAnimations()
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Start Playing" : "Next") {
                            if currentPage == pages.count - 1 {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    appState.completeOnboarding()
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                    resetAnimations()
                                    startAnimations()
                                }
                            }
                        }
                        .buttonStyle(GoldenButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .opacity(animateButton ? 1.0 : 0.0)
                    .offset(y: animateButton ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: animateButton)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimations()
            showGlow = true
        }
        .onChange(of: currentPage) { _ in
            resetAnimations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateTitle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateSubtitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateButton = true
            }
        }
    }
    
    private func resetAnimations() {
        animateTitle = false
        animateSubtitle = false
        animateButton = false
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let description: String
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
