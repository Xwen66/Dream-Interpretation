//
//  HomeScreen.swift (ContentView)
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            // Main Dashboard Tab
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // Dream List Tab
            NavigationStack {
                ListScreen()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Dreams")
            }
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .accentColor(.blue)
    }
}

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Text("Good Morning")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Ready to explore your dreams?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Quick Stats Dashboard
                HStack(spacing: 15) {
                    DashboardCard(
                        icon: "moon.stars.fill",
                        title: "Dreams",
                        value: "12",
                        color: .blue
                    )
                    
                    DashboardCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "This Week",
                        value: "3",
                        color: .green
                    )
                    
                    DashboardCard(
                        icon: "heart.fill",
                        title: "Insights",
                        value: "8",
                        color: .pink
                    )
                }
                
                // Main Actions
                VStack(spacing: 15) {
                    NavigationLink(destination: InputScreen()) {
                        ActionCard(
                            icon: "plus.circle.fill",
                            title: "Record New Dream",
                            subtitle: "Capture and interpret your latest dream",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: ListScreen()) {
                        ActionCard(
                            icon: "list.bullet.circle.fill",
                            title: "View Dream History",
                            subtitle: "Browse your previous dream interpretations",
                            color: .purple
                        )
                    }
                    
                    NavigationLink(destination: StatsView()) {
                        ActionCard(
                            icon: "chart.bar.fill",
                            title: "Dream Insights",
                            subtitle: "Discover patterns in your dreams",
                            color: .orange
                        )
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DashboardCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatsView: View {
    var body: some View {
        Text("Dream Insights Coming Soon")
            .font(.title2)
            .foregroundColor(.secondary)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    Text("Profile")
                }
                
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    Text("Notifications")
                }
            }
            
            Section("App") {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.purple)
                    Text("Dark Mode")
                }
                
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Help & Support")
                }
            }
            
            Section {
                Button(action: {
                    authManager.logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

// Keep ContentView for compatibility
struct ContentView: View {
    var body: some View {
        HomeScreen()
    }
}

#Preview {
    HomeScreen()
        .environmentObject(AuthManager())
}
