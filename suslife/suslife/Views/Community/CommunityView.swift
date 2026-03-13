//
//  CommunityView.swift
//  suslife
//
//  Community View - Personal progress tracking (REAL DATA ONLY)
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var rankingService = PersonalRankingService()
    @StateObject private var achievementService = AchievementService()
    
    // Direct data from repository
    @State private var totalCO2Saved: Double = 0
    @State private var totalActivities: Int = 0
    @State private var currentStreak: Int = 0
    @State private var isLoading = false
    
    private let repository = CoreDataActivityRepository()
    private let userProfileRepository: UserRepositoryProtocol = LocalUserRepository()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    // 1. Progress Summary Card
                    progressSummaryCard
                    
                    // 2. Weekly Comparison
                    if let comparison = rankingService.performanceComparison {
                        weeklyComparisonCard(comparison: comparison)
                    }
                    
                    // 3. Monthly Trend Chart (Coming Soon)
                    monthlyTrendChart
                    
                    // 4. Personal Best
                    personalBestCard
                    
                    // 5. Achievements
                    achievementsSection
                }
            }
            .padding()
        }
        .navigationTitle("My Progress")
        .task {
            await loadData()
            await achievementService.checkAchievements()
        }
        .refreshable {
            await loadData()
        }
    }
    
    // MARK: - Subviews
    
    private var progressSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary)
                
                Text("Your Impact")
                    .font(Fonts.title2)
                    .fontWeight(.bold)
            }
            
            Divider()
            
            // Total CO2 Saved
            statRow(
                icon: "drop.fill",
                iconColor: AppColors.accent,
                title: "Total CO₂ Saved",
                value: String(format: "%.1f lbs", totalCO2Saved)
            )
            
            // Total Activities
            statRow(
                icon: "checkmark.circle.fill",
                iconColor: AppColors.primary,
                title: "Total Activities",
                value: "\(totalActivities)"
            )
            
            // Current Streak
            statRow(
                icon: "flame.fill",
                iconColor: .orange,
                title: "Current Streak",
                value: "\(currentStreak) days"
            )
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func statRow(
        icon: String,
        iconColor: Color,
        title: String,
        value: String
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .font(Fonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Fonts.headline)
                .foregroundColor(AppColors.textPrimary)
        }
    }
    
    private func weeklyComparisonCard(comparison: PerformanceComparison) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary)
                
                Text("Weekly Comparison")
                    .font(Fonts.title3)
                    .fontWeight(.bold)
            }
            
            HStack(spacing: 20) {
                // This Week
                VStack(alignment: .leading, spacing: 8) {
                    Text("This Week")
                        .font(Fonts.footnote)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(String(format: "%.1f lbs", comparison.current.totalCO2))
                        .font(Fonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Divider()
                
                // Last Week
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Week")
                        .font(Fonts.footnote)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let previous = comparison.previous {
                        Text(String(format: "%.1f lbs", previous.totalCO2))
                            .font(Fonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                    } else {
                        Text("No data")
                            .font(Fonts.footnote)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Change indicator
            if comparison.changePercent != 0 {
                HStack {
                    Image(systemName: comparison.isImproved ? "arrow.down.right" : "arrow.up.right")
                        .foregroundColor(comparison.isImproved ? .green : .orange)
                    
                    Text(String(format: "%+.1f%%", comparison.changePercent))
                        .font(Fonts.headline)
                        .foregroundColor(comparison.isImproved ? .green : .orange)
                    
                    Text(comparison.isImproved ? "improvement!" : "more than last week")
                        .font(Fonts.footnote)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var monthlyTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Trend")
                .font(Fonts.title3)
                .fontWeight(.bold)
            
            // TODO: Implement chart using Swift Charts
            // For now, show placeholder
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Coming Soon")
                    .font(Fonts.headline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var personalBestCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Best")
                .font(Fonts.title3)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                HStack {
                    Label("Best Week", systemImage: "trophy.fill")
                    Spacer()
                    Text("Coming Soon")
                        .font(Fonts.footnote)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack {
                    Label("Longest Streak", systemImage: "flame.fill")
                    Spacer()
                    Text("\(currentStreak) days")
                        .font(Fonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(Fonts.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(achievementService.getUnlockedCount())/\(achievementService.achievements.count)")
                    .font(Fonts.footnote)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Show recently unlocked
            if !achievementService.recentlyUnlocked.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(achievementService.recentlyUnlocked) { achievement in
                            AchievementCardView(achievement: achievement)
                                .frame(width: 200)
                        }
                    }
                }
            }
            
            // Show top achievements
            let unlocked = achievementService.achievements.filter { $0.isUnlocked }.prefix(3)
            VStack(spacing: 8) {
                ForEach(unlocked) { achievement in
                    HStack {
                        Image(systemName: achievement.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(achievement.title)
                                .font(Fonts.headline)
                            Text(achievement.description)
                                .font(Fonts.footnote)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(AppColors.cardBackground.opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Methods
    
    private func loadData() async {
        isLoading = true
        
        do {
            // Load ranking data
            try await rankingService.loadCurrentWeekPerformance()
            try await rankingService.loadPerformanceComparison()
            
            // Load statistics
            totalCO2Saved = try await repository.calculateTotalCO2Saved()
            totalActivities = try await repository.fetchTotalActivities()
            // Get streak from UserProfile (convert weeks to days for display)
            let profile = try await userProfileRepository.getUserProfile()
            currentStreak = Int(profile.weeklyStreak) * 7  // Convert weeks to days
        } catch {
            print("Error loading progress data: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationView {
        CommunityView()
    }
}
