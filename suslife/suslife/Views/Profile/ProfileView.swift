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
    @State private var showEditProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileHeader(
                    stats: viewModel.userStats,
                    onEdit: { showEditProfile = true }
                )
                
                DetailedStatsCard(stats: viewModel.userStats)
                
                AchievementWall(
                    achievements: viewModel.achievements,
                    onTapAction: { showAchievementList = true }
                )
                
                ImpactSummary(stats: viewModel.userStats)
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
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(stats: $viewModel.userStats)
        }
    }
}

struct ProfileHeader: View {
    let stats: UserStats
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primary)
                }
            }
            
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

struct DetailedStatsCard: View {
    let stats: UserStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Statistics")
                .font(Fonts.title3)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatDetailItem(
                    icon: "leaf.fill",
                    label: "Total CO2 Saved",
                    value: String(format: "%.0f", stats.totalCO2Saved),
                    unit: "lbs",
                    color: AppColors.primary
                )
                
                StatDetailItem(
                    icon: "checkmark.circle.fill",
                    label: "Activities Logged",
                    value: String(stats.totalActivities),
                    unit: "total",
                    color: AppColors.accent
                )
                
                StatDetailItem(
                    icon: "flame.fill",
                    label: "Current Streak",
                    value: String(stats.currentStreak),
                    unit: "days",
                    color: AppColors.warning
                )
                
                StatDetailItem(
                    icon: "calendar",
                    label: "Days Active",
                    value: String(calculateDaysActive()),
                    unit: "days",
                    color: AppColors.success
                )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func calculateDaysActive() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: stats.joinDate, to: Date())
        return components.day ?? 0
    }
}

struct StatDetailItem: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(label)
                    .font(Fonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(unit)
                    .font(Fonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
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

struct ImpactSummary: View {
    let stats: UserStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Environmental Impact")
                .font(Fonts.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ImpactRow(
                    icon: "tree.fill",
                    description: "Equivalent to planting",
                    value: String(format: "%.0f", max(0, stats.totalCO2Saved / 48)),
                    unit: "trees"
                )
                
                ImpactRow(
                    icon: "car.side.fill",
                    description: "Equivalent to removing",
                    value: String(format: "%.0f", max(0, stats.totalCO2Saved / 8800)),
                    unit: "cars for a year"
                )
                
                ImpactRow(
                    icon: "bolt.fill",
                    description: "Equivalent to saving",
                    value: String(format: "%.0f", max(0, stats.totalCO2Saved * 0.453)),
                    unit: "kWh of energy"
                )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct ImpactRow: View {
    let icon: String
    let description: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.accent)
                .frame(width: 30)
            
            Text("\(description) **\(value) \(unit)**")
                .font(Fonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
}

struct EditProfileView: View {
    @Binding var stats: UserStats
    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String = "Eco Warrior"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Display Name")
                        Spacer()
                        TextField("Eco Warrior", text: $displayName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Member Since")
                        Spacer()
                        Text(joinDateFormatted)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Statistics")) {
                    LabeledContent("Total CO2 Saved", value: String(format: "%.0f lbs", stats.totalCO2Saved))
                    LabeledContent("Activities Logged", value: String(stats.totalActivities))
                    LabeledContent("Current Streak", value: "\(stats.currentStreak) days")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var joinDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: stats.joinDate)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
