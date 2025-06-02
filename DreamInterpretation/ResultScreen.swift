//
//  ResultScreen.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI

struct ResultScreen: View {
    let dreamText: String?
    let dreamEntry: DreamEntry?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var isLoading = false
    
    // Initialize with either new dream text or existing dream entry
    init(dreamText: String) {
        self.dreamText = dreamText
        self.dreamEntry = nil
    }
    
    init(dreamEntry: DreamEntry) {
        self.dreamText = nil
        self.dreamEntry = dreamEntry
    }
    
    private var currentDreamText: String {
        dreamText ?? dreamEntry?.dreamText ?? ""
    }
    
    private var interpretation: String {
        if let dreamEntry = dreamEntry {
            return dreamEntry.interpretation
        } else {
            // Sample interpretation for new dreams (simulated AI response)
            return """
            Your dream reveals fascinating insights about your subconscious mind. The elements in your dream suggest a period of personal growth and transformation.
            
            **Key Symbols:**
            • The imagery represents your inner desires for freedom and exploration
            • Water elements indicate emotional cleansing and renewal
            • Flying or elevated perspectives suggest rising above challenges
            
            **Emotional Themes:**
            This dream reflects your current life situation where you're seeking clarity and direction. The positive elements suggest optimism about upcoming changes.
            
            **Guidance:**
            Consider embracing new opportunities that align with your authentic self. Trust your intuition during this transformative period.
            """
        }
    }
    
    private var dreamTitle: String {
        dreamEntry?.title ?? "Your Dream Interpretation"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header Section
                VStack(spacing: 15) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text(dreamTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if let entry = dreamEntry {
                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Generated just now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                // Dream Text Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Your Dream", icon: "moon.fill")
                    
                    Text(currentDreamText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Interpretation Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "AI Interpretation", icon: "brain.head.profile")
                    
                    if isLoading {
                        LoadingView()
                    } else {
                        Text(interpretation)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Mood Section (if from existing entry)
                if let entry = dreamEntry {
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Mood", icon: "heart.fill")
                        
                        HStack {
                            MoodBadge(mood: entry.mood)
                            Spacer()
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    if dreamText != nil {
                        // New dream actions
                        Button(action: {
                            // Save dream functionality - UI only
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                Text("Save Dream")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Interpretation")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    if dreamEntry != nil {
                        Button(action: {
                            // Edit dream functionality - UI only
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Dream")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Interpretation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [interpretation])
        }
        .onAppear {
            if dreamText != nil {
                // Simulate API loading for new dreams
                simulateInterpretationLoading()
            }
        }
    }
    
    private func simulateInterpretationLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("AI is analyzing your dream...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview("New Dream Result") {
    NavigationStack {
        ResultScreen(dreamText: "I was flying over a beautiful city with golden buildings and clear blue skies. I felt free and peaceful, soaring through the clouds without any fear.")
    }
}

#Preview("Existing Dream Result") {
    NavigationStack {
        ResultScreen(dreamEntry: DreamEntry(
            id: UUID(),
            title: "Flying Over the City",
            dreamText: "I was soaring through the clouds above a beautiful cityscape...",
            interpretation: "Flying dreams often represent freedom and ambition...",
            date: Date(),
            mood: "Excited"
        ))
    }
} 