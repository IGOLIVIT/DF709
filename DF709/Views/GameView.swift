//
//  GameView.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var gameState: GameState
    @State private var animateGrid = false
    @State private var showCompletionAnimation = false
    
    init(gameState: GameState) {
        self._gameState = StateObject(wrappedValue: gameState)
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Game Stats
                gameStatsView
                
                Spacer(minLength: 20)
                
                // Memory Card Grid
                cardGridView
                
                Spacer(minLength: 20)
                
                // Instructions
                instructionsView
                
                Spacer(minLength: 30)
            }
            
            // Completion overlay
            if showCompletionAnimation {
                completionOverlay
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateGrid = true
            }
        }
        .onChange(of: gameState.isCompleted) { completed in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        showCompletionAnimation = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        appState.completeLevel(reward: gameState.score)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                appState.navigateTo(.mainMenu)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            // Back button
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
            
            // Level info
            VStack(spacing: 2) {
                Text("Level \(gameState.level.id)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Memory Game")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(ColorTheme.mediumGrey)
            }
            
            Spacer()
            
            // Reset button
            Button(action: {
                gameState.resetGame()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ColorTheme.turquoise)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var gameStatsView: some View {
        HStack(spacing: 30) {
            StatItem(title: "Score", value: "\(gameState.score)", color: ColorTheme.primaryGold)
            StatItem(title: "Moves", value: "\(gameState.moves)", color: ColorTheme.turquoise)
            
            if let timeRemaining = gameState.timeRemaining {
                StatItem(title: "Time", value: "\(timeRemaining)s", color: timeRemaining < 10 ? ColorTheme.secondaryRed : .white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    private var cardGridView: some View {
        let columns = gridColumns(for: gameState.cards.count)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(gameState.cards) { card in
                CardView(card: card) {
                    gameState.flipCard(card)
                }
                .scaleEffect(animateGrid ? 1.0 : 0.8)
                .opacity(animateGrid ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double.random(in: 0...0.5)), value: animateGrid)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 10) {
            Text("Tap cards to flip them and find matching pairs")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(ColorTheme.mediumGrey)
                .multilineTextAlignment(.center)
            
            if gameState.isCompleted {
                Text("🎉 All pairs found! 🎉")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.primaryGold)
                    .glow(color: ColorTheme.primaryGold, radius: 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private var completionOverlay: some View {
        ZStack {
            ColorTheme.background.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Success animation
                ZStack {
                    Circle()
                        .fill(ColorTheme.goldGradient)
                        .frame(width: 120, height: 120)
                        .glow(color: ColorTheme.primaryGold, radius: 30)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.black)
                }
                .scaleEffect(showCompletionAnimation ? 1.0 : 0.5)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showCompletionAnimation)
                
                VStack(spacing: 10) {
                    Text("Level Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.primaryGold)
                    
                    Text("Score: \(gameState.score) points")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Moves: \(gameState.moves)")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(ColorTheme.mediumGrey)
                }
                .opacity(showCompletionAnimation ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: showCompletionAnimation)
            }
        }
    }
    
    private func gridColumns(for cardCount: Int) -> [GridItem] {
        let columnsCount: Int
        switch cardCount {
        case ...8: columnsCount = 4
        case ...12: columnsCount = 4
        case ...16: columnsCount = 4
        default: columnsCount = 5
        }
        
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: columnsCount)
    }
}

struct CardView: View {
    let card: Card
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cardBorderColor, lineWidth: 2)
                    )
                    .frame(width: cardSize, height: cardSize)
                
                if card.isFlipped || card.isMatched {
                    // Front of card (symbol)
                    Image(systemName: card.symbol.rawValue)
                        .font(.system(size: cardSize * 0.4, weight: .medium))
                        .foregroundColor(symbolColor)
                        .scaleEffect(card.isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: card.isAnimating)
                } else {
                    // Back of card
                    VStack(spacing: 4) {
                        Image(systemName: "questionmark")
                            .font(.system(size: cardSize * 0.3, weight: .medium))
                            .foregroundColor(ColorTheme.mediumGrey)
                        
                        Text("?")
                            .font(.system(size: cardSize * 0.15, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.mediumGrey)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(card.isMatched ? 1.1 : 1.0)
        .opacity(card.isMatched ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: card.isMatched)
        .rotation3DEffect(
            .degrees(card.isFlipped || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.3), value: card.isFlipped)
    }
    
    private var cardSize: CGFloat {
        return 70 // Fixed size instead of calculating from screen bounds
    }
    
    private var cardBackgroundColor: Color {
        if card.isMatched {
            return ColorTheme.primaryGold.opacity(0.2)
        } else if card.isFlipped {
            return ColorTheme.darkGrey.opacity(0.8)
        } else {
            return ColorTheme.darkGrey.opacity(0.6)
        }
    }
    
    private var cardBorderColor: Color {
        if card.isMatched {
            return ColorTheme.primaryGold
        } else if card.isFlipped {
            return ColorTheme.turquoise
        } else {
            return ColorTheme.mediumGrey.opacity(0.5)
        }
    }
    
    private var symbolColor: Color {
        switch card.symbol.color {
        case "gold": return ColorTheme.primaryGold
        case "red": return ColorTheme.secondaryRed
        case "green": return Color.green
        case "turquoise": return ColorTheme.turquoise
        default: return .white
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(ColorTheme.mediumGrey)
        }
    }
}

#Preview {
    GameView(gameState: GameState(level: GameLevels.level(for: 1)))
        .environmentObject(AppState())
}