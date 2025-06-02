//
//  DreamInterpretationApp.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI

@main
struct DreamInterpretationApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                HomeScreen()
                    .environmentObject(authManager)
            } else {
                LoginScreen()
                    .environmentObject(authManager)
            }
        }
    }
}

// Simple authentication state manager
class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    
    func login() {
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
    }
}
