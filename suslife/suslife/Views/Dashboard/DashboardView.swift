//
//  DashboardView.swift
//  suslife
//
//  Dashboard - Main screen showing today's footprint and weekly trends
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var recommendationService = RecommendationService()
    @StateObject private var achievementService = AchievementService()
    @State private var showingLogSheet = false
    @State private var selectedCategory: String? = nil
    @State private var recommendations: [Recommendation] = []
    @State private var activityObserver: NSObjectProtocol?
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        TodayFootprintCard(
                            todayCO2: viewModel.todayCO2,
                            changePercent: viewModel.changePercent,
                            dailyGoal: viewModel.dailyGoal
                        )
                        
                        WeeklyTrendChart(data: viewModel.weeklyData)
                        
                        QuickActionButtons { category in
                            selectedCategory = category
                            showingLogSheet = true
                        }
                        
                        if !recommendations.isEmpty {
                            RecommendationsCard(recommendations: recommendations)
                        }
                        
                        RecentAchievementsCard(
                            achievements: achievementService.recentlyUnlocked
                        )
                    }
                    .padding()
                }
                
                if achievementService.showUnlockPopup,
                   let achievement = achievementService.currentUnlockAchievement {
                    AchievementUnlockPopup(
                        achievement: achievement,
                        isPresented: $achievementService.showUnlockPopup
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationTitle("Sustainable Life")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingLogSheet) {
                if let category = selectedCategory {
                    LogActivityView(
                        category: category,
                        viewModel: viewModel,
                        achievementService: achievementService
                    )
                }
            }
            .task {
                await viewModel.loadData()
                await achievementService.checkAchievements()
                recommendations = (try? await recommendationService.getRecommendations()) ?? []
            }
            .onAppear {
                setupActivityObserver()
            }
            .onDisappear {
                if let observer = activityObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
    }
    
    private func setupActivityObserver() {
        activityObserver = ActivityEvent.observeActivitySaved { co2Amount, category in
            Task {
                await viewModel.loadData()
                await achievementService.checkAchievements()
                recommendations = (try? await recommendationService.getRecommendations()) ?? []
            }
        }
    }
}

// MARK: - Today Footprint Card

struct TodayFootprintCard: View {
    let todayCO2: Double
    let changePercent: Double
    let dailyGoal: Double
    
    var progress: Double {
        min(todayCO2 / dailyGoal, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Footprint")
                        .font(Fonts.headline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(String(format: "%.1f", todayCO2))
                            .font(Fonts.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        
                        Text("lbs CO₂")
                            .font(Fonts.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                CircularProgressRing(progress: progress, size: 70)
            }
            
            if changePercent != 0 {
                HStack(spacing: 4) {
                    Image(systemName: changePercent < 0 ? "arrow.down.right" : "arrow.up.right")
                        .foregroundColor(changePercent < 0 ? AppColors.success : AppColors.warning)
                    
                    Text(String(format: "%.0f%% vs yesterday", abs(changePercent)))
                        .font(Fonts.footnote)
                        .foregroundColor(changePercent < 0 ? AppColors.success : AppColors.warning)
                }
            }
            
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .tint(progress > 0.8 ? AppColors.warning : AppColors.primary)
                
                HStack {
                    Text("Daily Goal: \(String(format: "%.0f", dailyGoal)) lbs")
                        .font(Fonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(Fonts.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct CircularProgressRing: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.primary.opacity(0.2), lineWidth: 8)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.primary,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            VStack(spacing: 2) {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("goal")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Weekly Trend Chart

struct WeeklyTrendChart: View {
    let data: [DailyTotal]
    
    var maxCO2: Double {
        data.map { $0.totalCO2 }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(Fonts.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 8) {
                ForEach(data) { item in
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.divider)
                                .frame(height: 100)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.primary)
                                .frame(height: CGFloat(item.totalCO2 / maxCO2) * 100)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text(dayLabel(for: item.date))
                            .font(Fonts.caption2)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(String(format: "%.0f", item.totalCO2))
                            .font(Fonts.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Quick Action Buttons

struct QuickActionButtons: View {
    let onCategorySelected: (String) -> Void
    
    private let categories: [(String, String, String)] = [
        ("transport", "car.fill", "Transport"),
        ("food", "fork.knife", "Food"),
        ("shopping", "bag.fill", "Shopping"),
        ("energy", "bolt.fill", "Energy")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ Quick Log")
                .font(Fonts.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(categories, id: \.0) { category, icon, title in
                    Button(action: {
                        onCategorySelected(category)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary)
                            
                            Text(title)
                                .font(Fonts.caption1)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground.opacity(0.5))
        .cornerRadius(16)
    }
}

// MARK: - Recent Achievements Card

struct RecommendationsCard: View {
    let recommendations: [Recommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips to Reduce More")
                .font(Fonts.title3)
                .fontWeight(.semibold)
            
            ForEach(recommendations.prefix(3)) { recommendation in
                RecommendationRow(recommendation: recommendation)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct RecommendationRow: View {
    let recommendation: Recommendation
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: recommendation.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.title)
                    .font(Fonts.subheadline)
                    .fontWeight(.medium)
                
                Text(recommendation.formattedPotential + " potential")
                    .font(Fonts.caption1)
                    .foregroundColor(AppColors.accent)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct RecentAchievementsCard: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Achievements")
                .font(Fonts.title3)
                .fontWeight(.semibold)
            
            if achievements.isEmpty {
                Text("Log your first activity to earn achievements!")
                    .font(Fonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(achievements.prefix(3))) { achievement in
                    HStack(spacing: 12) {
                        Image(systemName: achievement.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.accent)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(achievement.title)
                                .font(Fonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(achievement.description)
                                .font(Fonts.footnote)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
