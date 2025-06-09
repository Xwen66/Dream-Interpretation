//
//  Models.swift
//  DreamInterpretation
//
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

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
