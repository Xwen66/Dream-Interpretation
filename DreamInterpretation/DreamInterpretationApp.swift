//
//  DreamInterpretationApp.swift
//  DreamInterpretation


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
