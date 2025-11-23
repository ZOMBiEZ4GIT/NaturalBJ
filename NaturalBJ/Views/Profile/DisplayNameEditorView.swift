//
//  DisplayNameEditorView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Display Name Editor View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Name editing sheet with character limit and profanity filter
struct DisplayNameEditorView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    @Binding var displayName: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    @State private var tempName: String
    @State private var showingWarning = false
    @State private var warningMessage = ""

    private let characterLimit = 20

    init(displayName: Binding<String>) {
        self._displayName = displayName
        self._tempName = State(initialValue: displayName.wrappedValue)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(white: 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    headerView

                    // Text field
                    nameTextField

                    // Character count
                    characterCount

                    // Preview section
                    previewSection

                    // Guidelines
                    guidelinesSection

                    Spacer()

                    // Warning if shown
                    if showingWarning {
                        warningView
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Display Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveName()
                    }
                    .fontWeight(.semibold)
                    .disabled(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            isTextFieldFocused = true
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 HEADER                                                        │
    // └─────────────────────────────────────────────────────────────────┘

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.text.rectangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text("Choose your display name for leaderboards")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ✏️ NAME TEXT FIELD                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var nameTextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Name")
                .font(.caption)
                .foregroundColor(.gray)

            TextField("Enter your name", text: $tempName)
                .focused($isTextFieldFocused)
                .font(.title3)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.15))
                )
                .foregroundColor(.white)
                .onChange(of: tempName) { oldValue, newValue in
                    // Enforce character limit
                    if newValue.count > characterLimit {
                        tempName = String(newValue.prefix(characterLimit))
                    }
                }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔢 CHARACTER COUNT                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var characterCount: some View {
        HStack {
            Spacer()

            Text("\(tempName.count)/\(characterLimit)")
                .font(.caption)
                .foregroundColor(tempName.count >= characterLimit ? .red : .gray)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 👁️ PREVIEW SECTION                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.caption)
                .foregroundColor(.gray)

            // Mock leaderboard entry
            HStack(spacing: 12) {
                Text("#42")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(width: 50)

                Text("🎴")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tempName.isEmpty ? "Your Name" : tempName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.caption2)
                            Text("Lv 35")
                                .font(.caption)
                        }
                        .foregroundColor(.cyan)

                        Text("•")
                            .foregroundColor(.gray)

                        Text("Expert")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }

                Spacer()

                Text("15,000")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📋 GUIDELINES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private var guidelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guidelines")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 8) {
                guidelineRow(icon: "checkmark.circle", text: "Maximum \(characterLimit) characters", color: .green)
                guidelineRow(icon: "checkmark.circle", text: "No inappropriate content", color: .green)
                guidelineRow(icon: "info.circle", text: "Visible to other players", color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }

    private func guidelineRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)

            Text(text)
                .font(.caption)
                .foregroundColor(.white)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⚠️ WARNING VIEW                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private var warningView: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)

            Text(warningMessage)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow, lineWidth: 1)
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💾 SAVE NAME                                                     │
    // └─────────────────────────────────────────────────────────────────┘

    private func saveName() {
        let trimmedName = tempName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate
        guard !trimmedName.isEmpty else {
            showWarning("Name cannot be empty")
            return
        }

        // Basic profanity filter (very simple)
        if containsInappropriateContent(trimmedName) {
            showWarning("Please choose an appropriate name")
            return
        }

        // Save and dismiss
        displayName = trimmedName
        dismiss()
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔍 VALIDATION                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private func showWarning(_ message: String) {
        warningMessage = message
        showingWarning = true

        // Hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showingWarning = false
        }
    }

    /// Basic profanity filter (expand as needed)
    private func containsInappropriateContent(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        let blockedWords = ["fuck", "shit", "damn", "ass", "bitch"] // Basic list

        for word in blockedWords {
            if lowercased.contains(word) {
                return true
            }
        }

        return false
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    DisplayNameEditorView(displayName: .constant("Player"))
}
