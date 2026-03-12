//
//  UserRepositoryProtocol.swift
//  suslife
//
//  User Repository Protocol
//

import Foundation

/// Protocol defining the interface for user profile operations
protocol UserRepositoryProtocol {
    
    // MARK: - Read Operations
    
    /// Get current user profile
    func getUserProfile() async throws -> UserProfile
    
    // MARK: - Write Operations
    
    /// Create or update user profile with settings
    /// - Parameter settings: Profile settings including daily goal and preferences
    /// - Returns: Created or existing user profile
    /// - Throws: RepositoryError if creation fails
    func createUserProfile(settings: UserProfileSettings) async throws -> UserProfile
    
    /// Update user's daily CO2 goal
    /// - Parameter goal: New daily goal in lbs
    func updateDailyGoal(_ goal: Double) async throws
    
    /// Update user's weekly streak
    /// - Parameter streak: New streak count in weeks
    func updateStreak(_ streak: Int32) async throws
    
    /// Increment total activities logged counter
    func incrementActivityCount() async throws
    
    /// Save pending changes
    func save() async throws
}

/// User profile creation settings
struct UserProfileSettings {
    let dailyCO2Goal: Double
    let notificationsEnabled: Bool
    let healthKitEnabled: Bool
    let unitsSystem: String
}
