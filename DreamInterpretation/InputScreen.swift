//
//  InputScreen.swift
//  DreamInterpretation
//
//  Created by Simon Xie on 2025/5/26.
//

import SwiftUI

struct InputScreen: View {
    @State private var dreamText = ""
    @State private var navigateToResult = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Record Your Dream")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Describe your dream in as much detail as you can remember")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Dream Input Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Dream Description")
                        .font(.headline)
                    
                    TextEditor(text: $dreamText)
                        .frame(minHeight: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if dreamText.isEmpty {
                                    VStack {
                                        HStack {
                                            Text("I dreamed about...")
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 8)
                                                .padding(.top, 8)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        )
                }
                
                // Quick Prompts
                VStack(alignment: .leading, spacing: 15) {
                    Text("Need inspiration? Try these prompts:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        PromptButton(text: "Who was in your dream?") {
                            appendPrompt("People in my dream: ")
                        }
                        
                        PromptButton(text: "Where did it take place?") {
                            appendPrompt("Location: ")
                        }
                        
                        PromptButton(text: "What emotions did you feel?") {
                            appendPrompt("I felt: ")
                        }
                        
                        PromptButton(text: "What colors do you remember?") {
                            appendPrompt("Colors I remember: ")
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    NavigationLink(destination: ResultScreen(dreamText: dreamText)) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Interpret Dream")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button(action: {
                        dreamText = ""
                    }) {
                        Text("Clear")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("New Dream")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save Draft") {
                    // Save draft functionality - UI only
                }
                .disabled(dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func appendPrompt(_ prompt: String) {
        if !dreamText.isEmpty && !dreamText.hasSuffix("\n") {
            dreamText += "\n"
        }
        dreamText += prompt
    }
}

struct PromptButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationStack {
        InputScreen()
    }
} 