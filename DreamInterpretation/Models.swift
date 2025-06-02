//
//  Models.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct DreamEntry: Identifiable {
    let id: UUID
    let title: String
    let dreamText: String
    let interpretation: String
    let date: Date
    let mood: String
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