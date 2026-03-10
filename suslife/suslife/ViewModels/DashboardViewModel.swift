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
    
    // MARK: - Published Properties
    
    @Published var todayCO2: Double = 0
    @Published var changePercent: Double = 0
    @Published var dailyGoal: Double = 28.0 // lbs - average US daily footprint
    @Published var weeklyData: [DailyTotal] = []
    @Published var recentAchievements: [Achievement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let repository: ActivityRepositoryProtocol
    private let userProfileRepository: UserRepositoryProtocol
    
    init(
        repository: ActivityRepositoryProtocol = CoreDataActivityRepository(),
        userProfileRepository: UserRepositoryProtocol = LocalUserRepository()
    ) {
        self.repository = repository
        self.userProfileRepository = userProfileRepository
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch today's total
            todayCO2 = try await repository.fetchTodayTotalCO2()
            
            // Fetch weekly trend
            weeklyData = try await repository.fetchWeeklyTrend()
            
            // Calculate change percent
            await calculateChangePercent()
            
            // Load achievements
            await loadAchievements()
            
        } catch {
            errorMessage = error.localizedDescription
            print("Dashboard load error: \(error)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadData()
    }
    
    // MARK: - Private Methods
    
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
    
    private func loadAchievements() async {
        // TODO: Implement achievement loading
        // For now, show placeholder
        recentAchievements = []
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
