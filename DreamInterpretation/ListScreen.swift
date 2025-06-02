//
//  ListScreen.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI

struct ListScreen: View {
    @State private var searchText = ""
    
    // Sample dream data for UI demonstration
    private let sampleDreams = [
        DreamEntry(
            id: UUID(),
            title: "Flying Over the City",
            dreamText: "I was soaring through the clouds above a beautiful cityscape...",
            interpretation: "Flying dreams often represent freedom and ambition...",
            date: Date().addingTimeInterval(-86400),
            mood: "Excited"
        ),
        DreamEntry(
            id: UUID(),
            title: "Lost in a Forest",
            dreamText: "I found myself wandering through a dark, mysterious forest...",
            interpretation: "Forest dreams can symbolize exploration of the unconscious...",
            date: Date().addingTimeInterval(-172800),
            mood: "Anxious"
        ),
        DreamEntry(
            id: UUID(),
            title: "Meeting an Old Friend",
            dreamText: "I encountered my childhood friend in a bright, sunny meadow...",
            interpretation: "Dreams of old friends often reflect nostalgia and connection...",
            date: Date().addingTimeInterval(-259200),
            mood: "Happy"
        ),
        DreamEntry(
            id: UUID(),
            title: "Swimming with Dolphins",
            dreamText: "I was diving deep into crystal clear waters with playful dolphins...",
            interpretation: "Water dreams represent emotions and spiritual cleansing...",
            date: Date().addingTimeInterval(-345600),
            mood: "Peaceful"
        ),
        DreamEntry(
            id: UUID(),
            title: "Climbing a Mountain",
            dreamText: "I was ascending a steep mountain path with determination...",
            interpretation: "Mountain climbing dreams symbolize personal challenges...",
            date: Date().addingTimeInterval(-432000),
            mood: "Determined"
        )
    ]
    
    var filteredDreams: [DreamEntry] {
        if searchText.isEmpty {
            return sampleDreams
        } else {
            return sampleDreams.filter { dream in
                dream.title.localizedCaseInsensitiveContains(searchText) ||
                dream.dreamText.localizedCaseInsensitiveContains(searchText) ||
                dream.mood.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 10)
            
            if filteredDreams.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(searchText.isEmpty ? "No Dreams Yet" : "No Dreams Found")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(searchText.isEmpty ? 
                         "Start recording your dreams to see them here" : 
                         "Try adjusting your search terms")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if searchText.isEmpty {
                        NavigationLink(destination: InputScreen()) {
                            Text("Record First Dream")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
            } else {
                // Dreams List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredDreams) { dream in
                            NavigationLink(destination: ResultScreen(dreamEntry: dream)) {
                                DreamRowView(dream: dream)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
        .navigationTitle("My Dreams")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: InputScreen()) {
                    Image(systemName: "plus")
                        .font(.headline)
                }
            }
        }
    }
}

struct DreamRowView: View {
    let dream: DreamEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(dream.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                MoodBadge(mood: dream.mood)
            }
            
            // Dream preview
            Text(dream.dreamText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Footer with interpretation preview
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("Interpretation available")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ListScreen()
    }
} 