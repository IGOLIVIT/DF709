//
//  DF709App.swift
//  DF709
//
//  Created by IGOR on 05/09/2025.
//

import SwiftUI

@main
struct DF709App: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
