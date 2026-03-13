//
//  PersonalLeaderboardView.swift
//  suslife
//
//  Personal Leaderboard View - Track your personal progress
//

import SwiftUI

struct PersonalLeaderboardView: View {
    @StateObject private var rankingService = PersonalRankingService()
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Percentile ranking card
                percentileRankingCard
                
                // 2. This week's performance
                currentWeekCard
                
                // 3. Historical comparison
                comparisonSection
                
                // 4. Share button
                shareButton
            }
            .padding()
        }
        .navigationTitle("My Progress")
        .task {
            await loadData()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView()
        }
    }
    
    // MARK: - Subviews
    
    private var percentileRankingCard: some View {
        VStack(spacing: 16) {
            if let ranking = rankingService.percentileRanking {
                Image(systemName: ranking.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text(ranking.rank)
                    .font(Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(ranking.message)
                    .font(Fonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                ProgressView()
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var currentWeekCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.primary)
                Text("This Week")
                    .font(Fonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            if let performance = rankingService.currentWeekPerformance {
                HStack(spacing: 20) {
                    StatView(
                        title: "Total CO₂",
                        value: performance.formattedCO2,
                        icon: "leaf.fill"
                    )
                    
                    StatView(
                        title: "Activities",
                        value: "\(performance.activityCount)",
                        icon: "checkmark.circle.fill"
                    )
                    
                    StatView(
                        title: "Avg/Day",
                        value: String(format: "%.1f lbs", performance.averagePerDay),
                        icon: "chart.line.fill"
                    )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("vs Last Week")
                .font(Fonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if let comparison = rankingService.performanceComparison {
                ComparisonRow(
                    label: "Change",
                    value: comparison.changeDescription,
                    isPositive: comparison.isImproved
                )
                
                if let best = comparison.best {
                    ComparisonRow(
                        label: "vs Best Week",
                        value: "\(String(format: "%.1f", best.totalCO2)) lbs",
                        isPositive: false
                    )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var shareButton: some View {
        Button(action: { showingShareSheet = true }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share My Progress")
            }
            .font(Fonts.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.primary)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Methods
    
    private func loadData() async {
        do {
            try await rankingService.loadCurrentWeekPerformance()
            try await rankingService.loadPerformanceComparison()
            try await rankingService.calculatePercentileRanking()
        } catch {
            print("Error loading performance data: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primary)
            
            Text(value)
                .font(Fonts.headline)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(Fonts.footnote)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ComparisonRow: View {
    let label: String
    let value: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(Fonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(isPositive ? AppColors.success : AppColors.textPrimary)
        }
    }
}

struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
                
                Text("Share Feature Coming Soon!")
                    .font(Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Soon you'll be able to share your environmental achievements with friends and family.")
                    .font(Fonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .font(Fonts.headline)
                .foregroundColor(AppColors.primary)
                .padding()
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PersonalLeaderboardView()
    }
}
