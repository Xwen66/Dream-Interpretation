//
//  LoginScreen.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Dream Interpretation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Unlock the meaning of your dreams")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: {
                        authManager.login()
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Handle sign up - for UI only
                        authManager.login()
                    }) {
                        Text("Create Account")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Text("By signing in, you agree to our Terms of Service")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    LoginScreen()
        .environmentObject(AuthManager())
} 