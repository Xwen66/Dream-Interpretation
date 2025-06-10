//
//  Models.swift
//  DreamInterpretation
//
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - AI Service

class AIService: ObservableObject {
    private let apiKey = "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"
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func interpretDream(_ dreamText: String) async -> String {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        // Step 1: Generate prompt that combines with user input
        let prompt = """
        You are a dream interpreter. The following is a dream from me, interpret the dream for me:
        
        \(dreamText)
        
        Please provide a detailed interpretation that includes:
        1. Key symbols and their meanings
        2. Emotional themes present in the dream
        3. Possible connections to waking life
        4. Guidance or insights for personal growth
        
        Format your response in a clear, empathetic, and insightful manner.
        """
        
        let requestBody: [String: Any] = [
            "model": "anthropic/claude-3.5-sonnet",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        do {
            guard let url = URL(string: baseURL) else {
                await MainActor.run {
                    self.errorMessage = "Invalid API URL"
                    self.isLoading = false
                }
                return "Unable to connect to AI service."
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Dream-Interpretation-App", forHTTPHeaderField: "HTTP-Referer")
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                await MainActor.run {
                    self.isLoading = false
                }
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                // Try to parse error message
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = jsonResponse["error"] as? [String: Any],
                   let errorMessage = error["message"] as? String {
                    await MainActor.run {
                        self.errorMessage = "AI Error: \(errorMessage)"
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to parse AI response"
                        self.isLoading = false
                    }
                }
                return "Unable to interpret dream at this time. Please try again."
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
                self.isLoading = false
            }
            return "Unable to connect to AI service. Please check your internet connection."
        }
    }
}

// MARK: - Data Models

struct DreamEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let dreamText: String
    let interpretation: String
    let date: Date
    let mood: String
    let userId: String
    
    // Custom initializer for creating new dreams
    init(title: String, dreamText: String, interpretation: String, date: Date = Date(), mood: String, userId: String) {
        self.title = title
        self.dreamText = dreamText
        self.interpretation = interpretation
        self.date = date
        self.mood = mood
        self.userId = userId
    }
    
    // For backward compatibility with existing code
    init(id: UUID, title: String, dreamText: String, interpretation: String, date: Date, mood: String) {
        self.id = id.uuidString
        self.title = title
        self.dreamText = dreamText
        self.interpretation = interpretation
        self.date = date
        self.mood = mood
        self.userId = Auth.auth().currentUser?.uid ?? ""
    }
}

// MARK: - Firestore Manager

class FirestoreManager: ObservableObject {
    @Published var dreams: [DreamEntry] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        setupListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    // Set up real-time listener for user's dreams
    private func setupListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener = db.collection("dreams")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.dreams = documents.compactMap { document in
                    try? document.data(as: DreamEntry.self)
                }
            }
    }
    
    // Save a new dream
    func saveDream(_ dream: DreamEntry) async {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            try db.collection("dreams").addDocument(from: dream)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // Update an existing dream
    func updateDream(_ dream: DreamEntry) async {
        guard let dreamId = dream.id else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            try db.collection("dreams").document(dreamId).setData(from: dream)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // Delete a dream
    func deleteDream(_ dream: DreamEntry) async {
        guard let dreamId = dream.id else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            try await db.collection("dreams").document(dreamId).delete()
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // Refresh the listener when user changes
    func refreshForCurrentUser() {
        listener?.remove()
        dreams = []
        setupListener()
    }
}

// MARK: - Shared UI Components

struct MoodBadge: View {
    let mood: String
    
    private var moodColor: Color {
        switch mood.lowercased() {
        case "happy", "excited", "peaceful": return .green
        case "anxious", "scared", "worried": return .orange
        case "sad", "lonely": return .blue
        case "determined", "confident": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Text(mood)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(moodColor)
            .cornerRadius(8)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search dreams...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
} 
