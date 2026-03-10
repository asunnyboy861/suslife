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
    @Environment(\.dismiss) var dismiss
    @StateObject private var activityViewModel = LogActivityViewModel()
    
    @State private var selectedType: String = ""
    @State private var inputValue: String = ""
    @State private var notes: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var activityTypes: [String] {
        switch category {
        case "transport":
            return ["car", "bus", "train", "flight", "ev", "walking", "bicycle"]
        case "food":
            return ["beef", "chicken", "pork", "fish", "vegetarian", "vegan", "dairy"]
        case "shopping":
            return ["clothing", "electronics", "furniture", "books", "household"]
        case "energy":
            return ["electricity", "naturalGas", "propane", "solar", "wind"]
        default:
            return []
        }
    }
    
    private var unit: String {
        switch category {
        case "transport": return "mi"
        case "food": return "portion"
        case "shopping": return "item"
        case "energy": return "kWh"
        default: return ""
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
                // Activity Type Section
                Section(header: Text("Activity Type")) {
                    Picker("Select Activity", selection: $selectedType) {
                        Text("Select...").tag("")
                        ForEach(activityTypes, id: \.self) { type in
                            Text(type.capitalized).tag(type)
                        }
                    }
                }
                
                // Value Input Section
                if !selectedType.isEmpty {
                    Section(header: Text("Value")) {
                        HStack {
                            TextField("Enter value", text: $inputValue)
                                .keyboardType(.decimalPad)
                            
                            Text(unit)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    // Estimated CO2
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
                    
                    // Notes Section
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
                    .disabled(selectedType.isEmpty || inputValue.isEmpty)
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
        
        Task {
            do {
                try await activityViewModel.saveActivity(
                    category: category,
                    activityType: selectedType,
                    value: value,
                    unit: unit,
                    notes: notes.isEmpty ? nil : notes
                )
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
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
