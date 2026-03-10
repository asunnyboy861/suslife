//
//  AchievementListView.swift
//  suslife
//
//  Achievement List View - Shows all achievements by category
//

import SwiftUI

struct AchievementListView: View {
    @ObservedObject var achievementService: AchievementService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    progressHeader
                    
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        categorySection(for: category)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: achievementService.getProgressPercentage())
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(achievementService.getUnlockedCount())")
                        .font(.system(size: 28, weight: .bold))
                    Text("of \(achievementService.achievements.count)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("\(achievementService.totalXP) XP")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                if achievementService.getProgressPercentage() > 0 {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.red)
                        Text("\(streakDays) day streak")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
    
    private var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = Date()
        
        for _ in 0..<30 {
            let dayStart = calendar.startOfDay(for: date)
            let hasActivity = UserDefaults.standard.bool(forKey: "activity_\(dayStart.timeIntervalSince1970)")
            if hasActivity {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func categorySection(for category: AchievementCategory) -> some View {
        let categoryAchievements = achievementService.achievements.filter { $0.category == category }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(categoryAchievements) { achievement in
                    AchievementCardView(achievement: achievement)
                }
            }
        }
    }
}

struct AchievementListView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementListView(achievementService: AchievementService(repository: CoreDataActivityRepository()))
    }
}
