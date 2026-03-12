//
//  OnboardingState.swift
//  suslife
//
//  Onboarding State - Manages onboarding completion state
//

import Foundation
import Combine

final class OnboardingState: ObservableObject {
    static let shared = OnboardingState()
    
    @Published var isCompleted: Bool
    @Published var dailyGoal: Double
    
    private let onboardingCompletedKey = "onboarding_completed"
    private let dailyGoalKey = "onboarding_daily_goal"
    
    private init() {
        self.isCompleted = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        self.dailyGoal = UserDefaults.standard.double(forKey: dailyGoalKey)
        
        if dailyGoal == 0 {
            dailyGoal = 20.0
        }
    }
    
    func completeOnboarding(dailyGoal: Double) {
        isCompleted = true
        self.dailyGoal = dailyGoal
        
        UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
        UserDefaults.standard.set(dailyGoal, forKey: dailyGoalKey)
    }
    
    func resetOnboarding() {
        isCompleted = false
        UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
        UserDefaults.standard.removeObject(forKey: dailyGoalKey)
    }
}
