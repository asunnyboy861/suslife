//
//  ProfileView.swift
//  suslife
//
//  Profile View - User stats and achievements
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showAchievementList = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileHeader(stats: viewModel.userStats)
                
                StatsCard(stats: viewModel.userStats)
                
                AchievementWall(
                    achievements: viewModel.achievements,
                    onTapAction: { showAchievementList = true }
                )
            }
            .padding()
        }
        .navigationTitle("Profile")
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: $showAchievementList) {
            AchievementListView(achievementService: AchievementService(repository: CoreDataActivityRepository()))
        }
    }
}

struct ProfileHeader: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(AppColors.primary.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.primary)
                )
            
            Text("Eco Warrior")
                .font(Fonts.title2)
                .fontWeight(.semibold)
            
            Text("Member since \(joinDateFormatted)")
                .font(Fonts.footnote)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var joinDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: stats.joinDate)
    }
}

struct StatsCard: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Stats")
                .font(Fonts.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "leaf.fill",
                    value: String(format: "%.0f", stats.totalCO2Saved),
                    label: "Lbs Saved"
                )
                
                StatItem(
                    icon: "checkmark.circle.fill",
                    value: String(stats.totalActivities),
                    label: "Activities"
                )
                
                StatItem(
                    icon: "flame.fill",
                    value: String(stats.currentStreak),
                    label: "Day Streak"
                )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.accent)
            
            Text(value)
                .font(Fonts.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(Fonts.caption1)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AchievementWall: View {
    let achievements: [Achievement]
    let onTapAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(Fonts.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onTapAction) {
                    Text("See All")
                        .font(Fonts.caption1)
                        .foregroundColor(AppColors.accent)
                }
            }
            
            if achievements.isEmpty {
                Text("Start logging activities to earn achievements!")
                    .font(Fonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(achievements) { achievement in
                        VStack(spacing: 8) {
                            AchievementBadgeView(achievement: achievement, size: 48)
                            
                            Text(achievement.title)
                                .font(Fonts.caption1)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(height: 80)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
