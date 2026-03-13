//
//  LogActivityView.swift
//  suslife
//
//  Log Activity - Fast activity logging (< 10 seconds)
//

import SwiftUI

struct LogActivityView: View {
    let category: String
    @ObservedObject var viewModel: DashboardViewModel
    var achievementService: AchievementService?
    @Environment(\.dismiss) var dismiss
    @StateObject private var activityViewModel = LogActivityViewModel()
    
    @State private var selectedType: String = ""
    @State private var inputValue: String = ""
    @State private var notes: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    // Pre-computed activity types for faster rendering
    private let activityTypes: [String]
    private let unit: String
    
    init(
        category: String,
        viewModel: DashboardViewModel,
        achievementService: AchievementService? = nil
    ) {
        self.category = category
        self.viewModel = viewModel
        self.achievementService = achievementService
        
        // Pre-compute activity types and unit in initializer for instant rendering
        switch category {
        case "transport":
            self.activityTypes = ["car", "bus", "train", "flight", "ev", "walking", "bicycle"]
            self.unit = "mi"
        case "food":
            self.activityTypes = ["beef", "chicken", "pork", "fish", "vegetarian", "vegan", "dairy"]
            self.unit = "portion"
        case "shopping":
            self.activityTypes = ["clothing", "electronics", "furniture", "books", "household"]
            self.unit = "item"
        case "energy":
            self.activityTypes = ["electricity", "naturalGas", "propane", "solar", "wind"]
            self.unit = "kWh"
        default:
            self.activityTypes = []
            self.unit = ""
        }
    }
    
    private var estimatedCO2: Double {
        guard let value = Double(inputValue), value > 0 else {
            return 0
        }
        return CO2Calculator.calculate(
            category: category,
            activityType: selectedType,
            value: value
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Type")) {
                    Picker("Select Activity", selection: $selectedType) {
                        Text("Select...").tag("")
                        ForEach(activityTypes, id: \.self) { type in
                            Text(type.capitalized).tag(type)
                        }
                    }
                }
                
                if !selectedType.isEmpty {
                    Section(header: Text("Value")) {
                        HStack {
                            TextField("Enter value", text: $inputValue)
                                .keyboardType(.decimalPad)
                            
                            Text(unit)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    if inputValue.isEmpty == false, let _ = Double(inputValue) {
                        Section {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(AppColors.primary)
                                
                                Text("Estimated: \(String(format: "%.2f", estimatedCO2)) lbs CO₂")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    
                    Section(header: Text("Notes (optional)")) {
                        TextField("e.g., Commute to work", text: $notes)
                    }
                }
            }
            .navigationTitle("Log \(category.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveActivity()
                    }
                    .disabled(selectedType.isEmpty || inputValue.isEmpty || isSaving)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveActivity() {
        guard let value = Double(inputValue) else {
            errorMessage = "Please enter a valid number"
            showError = true
            return
        }
        
        isSaving = true
        
        Task {
            do {
                _ = try await activityViewModel.saveActivity(
                    category: category,
                    activityType: selectedType,
                    value: value,
                    unit: unit,
                    notes: notes.isEmpty ? nil : notes
                )
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Preview

struct LogActivityView_Previews: PreviewProvider {
    static var previews: some View {
        LogActivityView(
            category: "transport",
            viewModel: DashboardViewModel()
        )
    }
}
