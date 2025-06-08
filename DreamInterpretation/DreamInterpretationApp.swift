//
//  DreamInterpretationApp.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct DreamInterpretationApp: App {
    @StateObject private var authManager = AuthManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
