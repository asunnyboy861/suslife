//
//  LogActivityViewModel.swift
//  suslife
//
//  Log Activity ViewModel - Handles activity logging with validation
//

import Foundation
import SwiftUI

@MainActor
class LogActivityViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedCategory: String = ""
    @Published var selectedType: String = ""
    @Published var inputValue: String = ""
    @Published var notes: String = ""
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    
    // MARK: - Dependencies
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol = CoreDataActivityRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    func saveActivity(
        category: String,
        activityType: String,
        value: Double,
        unit: String,
        notes: String?
    ) async throws {
        // Create input model
        let input = ActivityInput(
            category: category,
            activityType: activityType,
            value: value,
            unit: unit,
            notes: notes,
            date: Date()
        )
        
        // Validate first
        let validation = input.validate()
        guard validation.isValid else {
            await MainActor.run {
                errorMessage = validation.error?.errorDescription ?? "Invalid input"
                showError = true
            }
            throw ValidationError.invalidCategory(category)
        }
        
        // Save if valid
        do {
            _ = try await repository.save(input)
            await MainActor.run {
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
            throw error
        }
    }
    
    func reset() {
        selectedCategory = ""
        selectedType = ""
        inputValue = ""
        notes = ""
        showError = false
        errorMessage = ""
        showSuccess = false
    }
}
