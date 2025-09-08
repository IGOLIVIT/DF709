//
//  AppState.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI
import Foundation

// MARK: - Game Models
enum CardSymbol: String, CaseIterable {
    case star = "star.fill"
    case heart = "heart.fill"
    case leaf = "leaf.fill"
    case flower = "flower.fill"
    case sun = "sun.max.fill"
    case moon = "moon.fill"
    case trophy = "trophy.fill"
    case gift = "gift.fill"
    
    var color: String {
        switch self {
        case .star, .sun, .trophy: return "gold"
        case .heart, .flower: return "red"
        case .leaf, .moon: return "green"
        case .gift: return "turquoise"
        }
    }
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let symbol: CardSymbol
    var isFlipped: Bool = false
    var isMatched: Bool = false
    var isAnimating: Bool = false
}

struct GameLevel {
    let id: Int
    let pairs: Int
    let timeLimit: Int? // seconds, nil for unlimited
    let reward: Int
    
    var totalCards: Int {
        return pairs * 2
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    var name: String
    var currentLevel: Int
    var totalPoints: Int
    var completedLevels: Set<Int>
    var hasSeenOnboarding: Bool
    
    init() {
        self.name = "Player"
        self.currentLevel = 1
        self.totalPoints = 0
        self.completedLevels = []
        self.hasSeenOnboarding = false
    }
}

// MARK: - App State Manager
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .onboarding
    @Published var userProfile: UserProfile
    @Published var currentGame: GameState?
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "UserProfile"
    
    init() {
        // Load user profile from UserDefaults
        if let data = userDefaults.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
            self.currentScreen = profile.hasSeenOnboarding ? .mainMenu : .onboarding
        } else {
            self.userProfile = UserProfile()
        }
    }
    
    func saveProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(data, forKey: profileKey)
        }
    }
    
    func completeOnboarding() {
        userProfile.hasSeenOnboarding = true
        currentScreen = .mainMenu
        saveProfile()
    }
    
    func startGame(level: Int) {
        let gameLevel = GameLevels.level(for: level)
        currentGame = GameState(level: gameLevel)
        currentScreen = .game
    }
    
    func completeLevel(reward: Int) {
        guard let game = currentGame else { return }
        
        userProfile.completedLevels.insert(game.level.id)
        userProfile.totalPoints += reward
        
        if game.level.id == userProfile.currentLevel {
            userProfile.currentLevel += 1
        }
        
        saveProfile()
        showAlert(message: "Level completed! +\(reward) points earned!")
    }
    
    func deleteProfile() {
        userDefaults.removeObject(forKey: profileKey)
        userProfile = UserProfile()
        currentScreen = .onboarding
    }
    
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
}

// MARK: - Screen Navigation
enum AppScreen {
    case onboarding
    case mainMenu
    case game
    case piggyBank
    case settings
}

// MARK: - Game State
class GameState: ObservableObject {
    @Published var cards: [Card] = []
    @Published var flippedCards: [Card] = []
    @Published var score: Int = 0
    @Published var moves: Int = 0
    @Published var timeRemaining: Int?
    @Published var isCompleted: Bool = false
    @Published var gameTimer: Timer?
    
    let level: GameLevel
    private var matchCheckTimer: Timer?
    
    init(level: GameLevel) {
        self.level = level
        self.timeRemaining = level.timeLimit
        setupGame()
        startTimer()
    }
    
    deinit {
        gameTimer?.invalidate()
        matchCheckTimer?.invalidate()
    }
    
    private func setupGame() {
        // Create pairs of cards
        let symbols = Array(CardSymbol.allCases.prefix(level.pairs))
        var gameCards: [Card] = []
        
        // Add two cards for each symbol
        for symbol in symbols {
            gameCards.append(Card(symbol: symbol))
            gameCards.append(Card(symbol: symbol))
        }
        
        // Shuffle the cards
        cards = gameCards.shuffled()
    }
    
    private func startTimer() {
        guard let timeLimit = level.timeLimit else { return }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let remaining = self.timeRemaining, remaining > 0 {
                self.timeRemaining = remaining - 1
            } else {
                self.gameTimer?.invalidate()
                // Game over - time's up
            }
        }
    }
    
    func flipCard(_ card: Card) {
        guard !card.isFlipped && !card.isMatched && flippedCards.count < 2 else { return }
        
        // Find and flip the card
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                cards[index].isFlipped = true
                cards[index].isAnimating = true
            }
            
            flippedCards.append(cards[index])
            
            // Check for match when two cards are flipped
            if flippedCards.count == 2 {
                moves += 1
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard flippedCards.count == 2 else { return }
        
        let card1 = flippedCards[0]
        let card2 = flippedCards[1]
        
        matchCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if card1.symbol == card2.symbol {
                // Match found!
                self.handleMatch(card1, card2)
            } else {
                // No match - flip cards back
                self.handleNoMatch(card1, card2)
            }
            
            self.flippedCards.removeAll()
        }
    }
    
    private func handleMatch(_ card1: Card, _ card2: Card) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            // Mark cards as matched
            if let index1 = cards.firstIndex(where: { $0.id == card1.id }) {
                cards[index1].isMatched = true
                cards[index1].isAnimating = false
            }
            if let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
                cards[index2].isMatched = true
                cards[index2].isAnimating = false
            }
            
            // Update score
            score += 10
        }
        
        // Check if game is complete
        if cards.allSatisfy({ $0.isMatched }) {
            completeGame()
        }
    }
    
    private func handleNoMatch(_ card1: Card, _ card2: Card) {
        withAnimation(.easeInOut(duration: 0.3)) {
            // Flip cards back
            if let index1 = cards.firstIndex(where: { $0.id == card1.id }) {
                cards[index1].isFlipped = false
                cards[index1].isAnimating = false
            }
            if let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
                cards[index2].isFlipped = false
                cards[index2].isAnimating = false
            }
        }
    }
    
    private func completeGame() {
        gameTimer?.invalidate()
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            isCompleted = true
        }
        
        // Bonus points for time remaining
        if let timeRemaining = timeRemaining {
            score += timeRemaining
        }
        
        // Bonus for fewer moves
        let perfectMoves = level.pairs
        if moves <= perfectMoves {
            score += 50 // Perfect game bonus
        }
    }
    
    func resetGame() {
        gameTimer?.invalidate()
        matchCheckTimer?.invalidate()
        
        cards.removeAll()
        flippedCards.removeAll()
        score = 0
        moves = 0
        timeRemaining = level.timeLimit
        isCompleted = false
        
        setupGame()
        startTimer()
    }
}

// MARK: - Game Levels
struct GameLevels {
    static func level(for id: Int) -> GameLevel {
        switch id {
        case 1:
            return GameLevel(
                id: 1,
                pairs: 3,
                timeLimit: nil, // No time limit for first level
                reward: 30
            )
        case 2:
            return GameLevel(
                id: 2,
                pairs: 4,
                timeLimit: 60,
                reward: 50
            )
        case 3:
            return GameLevel(
                id: 3,
                pairs: 5,
                timeLimit: 90,
                reward: 70
            )
        case 4:
            return GameLevel(
                id: 4,
                pairs: 6,
                timeLimit: 120,
                reward: 100
            )
        case 5:
            return GameLevel(
                id: 5,
                pairs: 7,
                timeLimit: 150,
                reward: 130
            )
        default:
            // Generate procedural levels
            let pairs = min(3 + (id - 1), 8) // Max 8 pairs (16 cards)
            let timeLimit = pairs > 3 ? pairs * 20 : nil
            return GameLevel(
                id: id,
                pairs: pairs,
                timeLimit: timeLimit,
                reward: pairs * 15 + id * 5
            )
        }
    }
}
