//
//  ContentView.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            
            Group {
                switch appState.currentScreen {
                case .onboarding:
                    OnboardingView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case .mainMenu:
                    MainMenuView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case .game:
                    if let gameState = appState.currentGame {
                        GameView(gameState: gameState)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                
                case .piggyBank:
                    PiggyBankView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case .settings:
                    SettingsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appState.currentScreen)
        }
        .alert(appState.alertMessage, isPresented: $appState.showingAlert) {
            Button("OK") {
                appState.showingAlert = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
