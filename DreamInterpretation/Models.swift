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
    private let apiKey = "sk_zuUNUD8XTjnOE6cPVUJICO6TPYAJipHLE9iKzbsx-iI"
    private let baseURL = "https://api.novita.ai/v3/openai/chat/completions"
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func interpretDream(_ dreamText: String) async -> String {
        print("🤖 Starting AI interpretation for dream text: \(dreamText.prefix(50))...")
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        // Step 1: Generate prompt that combines with user input
        let prompt = """
        Role: You're a professional dream interpreter using Jungian psychology, symbolic analysis, and positive psychology. Generate a response in this exact format with three distinct sections:

        === INTERPRETATION SECTION ===
        
        Overall Theme
        [20-40 word theme summary using "may suggest/could reflect". Connect to waking life.]

        Key Symbols Analysis
        [Symbol Name]
        [Psychological/cultural context]
        [Personalized interpretation]

        [Repeat for 3-5 key symbols found in the dream]

        Emotional Journey
        [Trace emotion progression through dream stages]

        Personal Insights
        [Actionable non-prescriptive suggestion]

        [Second suggestion]
        
        === LUCID DREAM GUIDANCE ===
        
        Dream Awareness Techniques
        [Specific techniques to become lucid in similar dreams]
        
        Reality Check Triggers
        [Elements from this dream that could serve as reality check triggers]
        
        Lucid Action Suggestions
        [What to try if you become lucid in a similar dream scenario]
        
        Practice Recommendations
        [Science-backed techniques for improving lucid dreaming based on dream content]
        
        === SYMBOLS FORMAT ===
        Symbol: [single word only] | Meaning: [brief positive meaning, 8 words max]
        Symbol: [single word only] | Meaning: [brief positive meaning, 8 words max]
        [Continue for each symbol found]

        Rules:
        - Prioritize emotions and key elements from the dream
        - For dark elements, provide light-based reframing and positive interpretations
        - NEVER diagnose conditions (use "may indicate stress")
        - NEVER predict futures
        - NEVER impose religious views
        - NEVER use absolute statements
        - NEVER include references, citations, or sources
        - For flying/water/falling: Reference Jungian archetypes
        - Include research-backed techniques for lucid dreaming
        - Max 5 symbols total
        - Use plain text formatting, no markdown syntax
        - Keep symbol meanings concise (10-15 words maximum)
        - Structure content with clear section headers for better readability
        - SYMBOLS MUST BE SINGLE WORDS ONLY (e.g., "Flying", "Water", "House", "Car")
        - GUIDANCE MUST BE POSITIVE, UPLIFTING, AND ENCOURAGING
        - Focus on growth, learning, and positive transformation in guidance
        - Reframe challenges as opportunities for personal development
        - FOLLOW THE EXACT FORMAT SHOWN IN THE EXAMPLE ABOVE

        **DREAM TO INTERPRET:**
        \(dreamText)
        """
        
        let requestBody: [String: Any] = [
            "model": "meta-llama/llama-3.1-8b-instruct",
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
                print("❌ Invalid API URL: \(baseURL)")
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
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            print("🌐 Making API request to: \(baseURL)")
            print("🔑 Using API key: \(apiKey.prefix(20))...")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ Non-200 status code: \(httpResponse.statusCode)")
                    
                    // Print response data for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("🔍 API Response: \(responseString)")
                    }
                }
            }
            
            // Parse the response
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Failed to parse JSON response")
                await MainActor.run {
                    self.errorMessage = "Invalid JSON response from API"
                    self.isLoading = false
                }
                return "Unable to interpret dream at this time. Please try again."
            }
            
            print("✅ Received JSON response: \(jsonResponse.keys)")
            
            // Check for API error first (Novita AI format)
            if let error = jsonResponse["error"] as? [String: Any] {
                let errorMessage = error["message"] as? String ?? "Unknown API error"
                let errorCode = error["code"] as? Int ?? 0
                let errorReason = error["reason"] as? String ?? "unknown"
                print("❌ API Error - Code: \(errorCode), Reason: \(errorReason), Message: \(errorMessage)")
                
                await MainActor.run {
                    self.errorMessage = "API Error: \(errorMessage)"
                    self.isLoading = false
                }
                return "Unable to interpret dream at this time. Please try again."
            }
            
            // Parse successful response
            if let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                print("✅ Successfully received AI interpretation")
                
                await MainActor.run {
                    self.isLoading = false
                }
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                print("❌ Failed to parse choices/message/content from response")
                print("🔍 Response structure: \(jsonResponse)")
                
                await MainActor.run {
                    self.errorMessage = "Failed to parse AI response"
                    self.isLoading = false
                }
                return "Unable to interpret dream at this time. Please try again."
            }
            
        } catch {
            print("❌ Network/Request error: \(error.localizedDescription)")
            
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
    var id: String?
    let title: String
    let dreamText: String
    let interpretation: String
    let date: Date
    let mood: String
    let userId: String
    
    // Computed property to check if this is a draft
    var isDraft: Bool {
        return interpretation == "Draft - No interpretation yet"
    }
    
    // Custom initializer for creating new dreams
    init(title: String, dreamText: String, interpretation: String, date: Date = Date(), mood: String, userId: String) {
        self.title = title
        self.dreamText = dreamText
        self.interpretation = interpretation
        self.date = date
        self.mood = mood
        self.userId = userId
    }
    
    // Initializer with existing ID for updates
    init(id: String?, title: String, dreamText: String, interpretation: String, date: Date, mood: String, userId: String) {
        self.id = id
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

// MARK: - Local Storage Manager (formerly Firestore Manager)

class FirestoreManager: ObservableObject {
    @Published var dreams: [DreamEntry] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    init() {
        loadDreamsForCurrentUser()
    }
    
    // Get the JSON file URL for a specific user
    private func dreamsFileURL(for userId: String) -> URL {
        return documentsDirectory.appendingPathComponent("dreams_\(userId).json")
    }
    
    // Load dreams for the current user from local JSON file
    private func loadDreamsForCurrentUser() {
        guard let userId = Auth.auth().currentUser?.uid else { 
            print("❌ No authenticated user found for loading dreams")
            dreams = []
            return 
        }
        
        print("📁 Loading dreams for user: \(userId)")
        loadDreams(for: userId)
    }
    
    // Load dreams from JSON file for specific user
    private func loadDreams(for userId: String) {
        let fileURL = dreamsFileURL(for: userId)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("📄 No dreams file found for user \(userId), starting with empty array")
            dreams = []
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedDreams = try decoder.decode([DreamEntry].self, from: data)
            
            DispatchQueue.main.async {
                self.dreams = decodedDreams.sorted { $0.date > $1.date }
                print("✅ Loaded \(decodedDreams.count) dreams for user \(userId)")
            }
        } catch {
            print("❌ Failed to load dreams: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load dreams: \(error.localizedDescription)"
                self.dreams = []
            }
        }
    }
    
    // Save dreams to JSON file for specific user
    private func saveDreamsToFile(for userId: String) {
        let fileURL = dreamsFileURL(for: userId)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(dreams)
            try data.write(to: fileURL)
            print("✅ Successfully saved \(dreams.count) dreams to file for user \(userId)")
        } catch {
            print("❌ Failed to save dreams to file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save dreams: \(error.localizedDescription)"
            }
        }
    }
    
    // Save a new dream
    func saveDream(_ dream: DreamEntry) async {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        // Check authentication
        guard let userId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                self.errorMessage = "User not authenticated"
                self.isLoading = false
            }
            print("❌ Cannot save dream: User not authenticated")
            return
        }
        
        // Create dream with unique ID and userId
        let dreamToSave = DreamEntry(
            id: UUID().uuidString,
            title: dream.title,
            dreamText: dream.dreamText,
            interpretation: dream.interpretation,
            date: dream.date,
            mood: dream.mood,
            userId: userId
        )
        
        print("💾 Attempting to save dream for user: \(userId)")
        print("📄 Dream title: \(dreamToSave.title)")
        
        await MainActor.run {
            // Add to current dreams array
            self.dreams.insert(dreamToSave, at: 0) // Insert at beginning for newest first
            self.dreams.sort { $0.date > $1.date } // Ensure proper sorting
        }
        
        // Save to file in background
        DispatchQueue.global(qos: .background).async {
            self.saveDreamsToFile(for: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                print("✅ Successfully saved dream: \(dreamToSave.id ?? "unknown")")
            }
        }
    }
    
    // Update an existing dream
    func updateDream(_ dream: DreamEntry) async {
        guard let dreamId = dream.id else { 
            print("❌ Cannot update dream: No document ID")
            return 
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                self.errorMessage = "User not authenticated"
                self.isLoading = false
            }
            print("❌ Cannot update dream: User not authenticated")
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        print("🔄 Attempting to update dream: \(dreamId)")
        
        await MainActor.run {
            // Find and update the dream in the array
            if let index = self.dreams.firstIndex(where: { $0.id == dreamId }) {
                self.dreams[index] = dream
                self.dreams.sort { $0.date > $1.date } // Maintain sorting
            }
        }
        
        // Save to file in background
        DispatchQueue.global(qos: .background).async {
            self.saveDreamsToFile(for: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                print("✅ Successfully updated dream: \(dreamId)")
            }
        }
    }
    
    // Delete a dream
    func deleteDream(_ dream: DreamEntry) async {
        guard let dreamId = dream.id else { 
            print("❌ Cannot delete dream: No document ID")
            return 
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                self.errorMessage = "User not authenticated"
                self.isLoading = false
            }
            print("❌ Cannot delete dream: User not authenticated")
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        print("🗑️ Attempting to delete dream: \(dreamId)")
        
        await MainActor.run {
            // Remove the dream from the array
            self.dreams.removeAll { $0.id == dreamId }
        }
        
        // Save to file in background
        DispatchQueue.global(qos: .background).async {
            self.saveDreamsToFile(for: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                print("✅ Successfully deleted dream: \(dreamId)")
            }
        }
    }
    
    // Refresh dreams when user changes
    func refreshForCurrentUser() {
        print("🔄 Refreshing dreams for current user")
        loadDreamsForCurrentUser()
    }
    
    // Get file path for debugging
    func getDreamsFilePath() -> String? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        return dreamsFileURL(for: userId).path
    }
    
    // Clear all dreams for current user (for debugging/reset)
    func clearAllDreams() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        await MainActor.run {
            self.dreams = []
        }
        
        let fileURL = dreamsFileURL(for: userId)
        try? fileManager.removeItem(at: fileURL)
        print("🗑️ Cleared all dreams for user: \(userId)")
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
