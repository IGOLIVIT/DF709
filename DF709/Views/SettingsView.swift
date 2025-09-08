//
//  SettingsView.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateContent = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile section
                        profileSection
                        
                        // Game settings
                        gameSettingsSection
                        
                        // Danger zone
                        dangerZoneSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
        .alert("Reset Application", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState.deleteProfile()
                }
            }
        } message: {
            Text("Are you sure you want to reset the application? This action cannot be undone. All progress and achievements will be lost.")
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
            
            Text("Settings")
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
    
    private var profileSection: some View {
        SettingsSection(title: "Profile", delay: 0.0) {
            VStack(spacing: 20) {
                // Profile avatar
                ZStack {
                    Circle()
                        .fill(ColorTheme.goldGradient)
                        .frame(width: 80, height: 80)
                        .glow(color: ColorTheme.primaryGold, radius: 10)
                    
                    Text(String(appState.userProfile.name.prefix(1)).uppercased())
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                
                VStack(spacing: 8) {
                    Text(appState.userProfile.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Level \(appState.userProfile.currentLevel) Player")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(ColorTheme.mediumGrey)
                }
                
                // Quick stats
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(appState.userProfile.totalPoints)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.primaryGold)
                        Text("Points")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(ColorTheme.mediumGrey)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(appState.userProfile.completedLevels.count)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.turquoise)
                        Text("Completed")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(ColorTheme.mediumGrey)
                    }
                }
            }
        }
    }
    
    private var gameSettingsSection: some View {
        SettingsSection(title: "Game", delay: 0.1) {
            VStack(spacing: 15) {
                SettingsRow(
                    icon: "gamecontroller.fill",
                    title: "Current Level",
                    value: "\(appState.userProfile.currentLevel)",
                    color: ColorTheme.primaryGold
                )
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Highest Level",
                    value: "\(appState.userProfile.currentLevel)",
                    color: ColorTheme.turquoise
                )
                
                SettingsRow(
                    icon: "trophy.fill",
                    title: "Total Achievements",
                    value: "\(appState.userProfile.completedLevels.count)",
                    color: ColorTheme.secondaryRed
                )
            }
        }
    }
    
    
    private var dangerZoneSection: some View {
        SettingsSection(title: "Danger Zone", delay: 0.2) {
            VStack(spacing: 15) {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ColorTheme.secondaryRed)
                        
                        Text("Reset App & All Achievements")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ColorTheme.secondaryRed)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ColorTheme.secondaryRed.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorTheme.secondaryRed.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.secondaryRed.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Text("This action will completely reset your progress, achievements and all collected points. This action cannot be undone.")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(ColorTheme.mediumGrey)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let delay: Double
    let content: Content
    
    @State private var animate = false
    
    init(title: String, delay: Double, @ViewBuilder content: () -> Content) {
        self.title = title
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                content
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorTheme.darkGrey.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ColorTheme.mediumGrey.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .opacity(animate ? 1.0 : 0.0)
        .offset(y: animate ? 0 : 20)
        .animation(.easeOut(duration: 0.8).delay(delay), value: animate)
        .onAppear {
            animate = true
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(ColorTheme.mediumGrey)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
