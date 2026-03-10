//
//  ProfileViewModel.swift
//  suslife
//
//  Profile ViewModel
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var userStats: UserStats = UserStats()
    @Published var achievements: [Achievement] = []
    @Published var showAchievementDetail = false
    
    private let repository: ActivityRepositoryProtocol
    private let userProfileRepository: UserRepositoryProtocol
    private var achievementService: AchievementService?
    
    init(
        repository: ActivityRepositoryProtocol = CoreDataActivityRepository(),
        userProfileRepository: UserRepositoryProtocol = LocalUserRepository()
    ) {
        self.repository = repository
        self.userProfileRepository = userProfileRepository
    }
    
    func loadData() async {
        do {
            let profile = try await userProfileRepository.getUserProfile()
            
            userStats = UserStats(
                totalCO2Saved: try await repository.calculateTotalCO2Saved(),
                totalActivities: try await repository.fetchTotalActivities(),
                currentStreak: try await repository.fetchActivityCount(for: .last7Days),
                joinDate: profile.joinDate
            )
            
            await loadAchievements()
            
        } catch {
            print("Profile load error: \(error)")
        }
    }
    
    private func loadAchievements() async {
        achievementService = AchievementService(repository: repository)
        await achievementService?.checkAchievements()
        
        if let service = achievementService {
            achievements = Array(service.achievements.prefix(6))
        }
    }
}

struct UserStats {
    var totalCO2Saved: Double = 0
    var totalActivities: Int = 0
    var currentStreak: Int = 0
    var joinDate: Date = Date()
}
