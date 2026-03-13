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
    private let achievementService: AchievementService
    
    init(
        repository: ActivityRepositoryProtocol = CoreDataActivityRepository(),
        achievementService: AchievementService
    ) {
        self.repository = repository
        self.achievementService = achievementService
    }
    
    // MARK: - Public Methods
    
    func saveActivity(
        category: String,
        activityType: String,
        value: Double,
        unit: String,
        notes: String?
    ) async throws -> Double {
        let input = ActivityInput(
            category: category,
            activityType: activityType,
            value: value,
            unit: unit,
            notes: notes,
            date: Date()
        )
        
        let validation = input.validate()
        guard validation.isValid else {
            await MainActor.run {
                errorMessage = validation.error?.errorDescription ?? "Invalid input"
                showError = true
            }
            throw ValidationError.invalidCategory(category)
        }
        
        do {
            let activity = try await repository.save(input)
            
            ActivityEvent.notifyActivitySaved(
                co2Amount: activity.co2Emission,
                category: category
            )
            
            // Check achievements immediately after saving
            // Note: Achievement check happens asynchronously
            Task {
                await achievementService.checkAchievements()
            }
            
            await MainActor.run {
                showSuccess = true
            }
            
            return activity.co2Emission
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
