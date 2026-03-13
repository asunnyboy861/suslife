//
//  ContactSupportView.swift
//  suslife
//
//  Contact Support - User feedback form with Cloudflare Worker backend
//

import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    @State private var selectedSubject: FeedbackSubject = .featureRequest
    @State private var customSubject: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    
    // MARK: - UI State
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showCustomSubject = false
    
    // MARK: - Constants
    private let workerURL = "https://feedback-board.iocompile67692.workers.dev"
    private let appName = "Sustainable Life Tracker"
    
    // MARK: - Feedback Subject Options
    enum FeedbackSubject: String, CaseIterable, Identifiable {
        case bugReport = "Bug Report"
        case featureRequest = "Feature Request"
        case performanceIssue = "Performance Issue"
        case uiFeedback = "UI/UX Feedback"
        case dataQuestion = "Data Question"
        case other = "Other"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .bugReport: return "ladybug.fill"
            case .featureRequest: return "lightbulb.fill"
            case .performanceIssue: return "bolt.fill"
            case .uiFeedback: return "paintbrush.fill"
            case .dataQuestion: return "chart.bar.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .bugReport: return .red
            case .featureRequest: return .yellow
            case .performanceIssue: return .orange
            case .uiFeedback: return .purple
            case .dataQuestion: return .blue
            case .other: return .gray
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Subject Selection Section
                Section(header: Text("What can we help you with?")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(FeedbackSubject.allCases) { subject in
                            SubjectButton(
                                subject: subject,
                                isSelected: selectedSubject == subject,
                                action: { selectSubject(subject) }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if showCustomSubject {
                        TextField("Enter custom subject", text: $customSubject)
                            .textInputAutocapitalization(.words)
                    }
                }
                
                // MARK: - Contact Information Section
                Section(header: Text("Contact Information")) {
                    TextField("Your Name", text: $name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Email Address", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                // MARK: - Message Section
                Section(header: Text("Message")) {
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Describe your issue or suggestion in detail...")
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $message)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                    }
                }
                
                // MARK: - Submit Section
                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            Spacer()
                            
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit Feedback")
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .listRowBackground(
                        isFormValid ? AppColors.primary : AppColors.primary.opacity(0.3)
                    )
                    .foregroundColor(.white)
                }
                
                // MARK: - Privacy Note
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(AppColors.textSecondary)
                            .font(.caption)
                        
                        Text("Your feedback is sent securely. We only use your email to respond to your inquiry.")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Thank You!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been submitted successfully. We'll get back to you soon.")
            }
            .alert("Submission Failed", isPresented: $showErrorAlert) {
                Button("Try Again", role: .none) {
                    submitFeedback()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !message.isEmpty &&
        (selectedSubject != .other || !customSubject.isEmpty)
    }
    
    private var finalSubject: String {
        if selectedSubject == .other {
            return customSubject.isEmpty ? "Other" : customSubject
        }
        return selectedSubject.rawValue
    }
    
    // MARK: - Methods
    
    private func selectSubject(_ subject: FeedbackSubject) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedSubject = subject
            showCustomSubject = (subject == .other)
        }
    }
    
    private func submitFeedback() {
        guard isFormValid else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await sendFeedbackToServer()
                await MainActor.run {
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func sendFeedbackToServer() async throws {
        guard let url = URL(string: "\(workerURL)/api/feedback") else {
            throw FeedbackError.invalidURL
        }
        
        let feedbackData: [String: String] = [
            "name": name,
            "email": email,
            "subject": finalSubject,
            "message": message,
            "app_name": appName
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: feedbackData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let errorMsg = errorJson["error"] {
                throw FeedbackError.serverError(errorMsg)
            }
            throw FeedbackError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool,
              success else {
            throw FeedbackError.submissionFailed
        }
    }
}

// MARK: - Subject Button Component

struct SubjectButton: View {
    let subject: ContactSupportView.FeedbackSubject
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: subject.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : subject.color)
                
                Text(subject.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? subject.color : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? subject.color : AppColors.textSecondary.opacity(0.2), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Error Types

enum FeedbackError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case submissionFailed
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL. Please try again later."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .serverError(let message):
            return "Server error: \(message)"
        case .submissionFailed:
            return "Failed to submit feedback. Please try again."
        case .networkError:
            return "Network connection failed. Please check your internet connection and try again."
        }
    }
}

// MARK: - Preview

struct ContactSupportView_Previews: PreviewProvider {
    static var previews: some View {
        ContactSupportView()
    }
}
