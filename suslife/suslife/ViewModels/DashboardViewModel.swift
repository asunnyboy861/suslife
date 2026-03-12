//
//  DashboardViewModel.swift
//  suslife
//
//  Dashboard ViewModel - State management for Dashboard
//

import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    
    @Published var todayCO2: Double = 0
    @Published var changePercent: Double = 0
    @Published var dailyGoal: Double = 28.0
    @Published var weeklyData: [DailyTotal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ActivityRepositoryProtocol
    private let userProfileRepository: UserRepositoryProtocol
    
    init(
        repository: ActivityRepositoryProtocol = CoreDataActivityRepository(),
        userProfileRepository: UserRepositoryProtocol = LocalUserRepository()
    ) {
        self.repository = repository
        self.userProfileRepository = userProfileRepository
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load user profile first to get the correct dailyGoal
            try await loadUserProfile()
            
            // Load activity data
            todayCO2 = try await repository.fetchTodayTotalCO2()
            weeklyData = try await repository.fetchWeeklyTrend()
            await calculateChangePercent()
        } catch {
            errorMessage = error.localizedDescription
            print("Dashboard load error: \(error)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadData()
    }
    
    /// Load user profile and update dailyGoal
    private func loadUserProfile() async throws {
        let profile = try await userProfileRepository.getUserProfile()
        dailyGoal = profile.dailyCO2Goal
    }
    
    private func calculateChangePercent() async {
        guard weeklyData.count >= 2 else {
            changePercent = 0
            return
        }
        
        let yesterday = weeklyData[safe: weeklyData.count - 2]?.totalCO2 ?? 0
        let today = todayCO2
        
        if yesterday > 0 {
            changePercent = ((today - yesterday) / yesterday) * 100
        } else {
            changePercent = today > 0 ? 100 : 0
        }
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
