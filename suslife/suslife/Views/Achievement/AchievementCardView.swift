//
//  AchievementCardView.swift
//  suslife
//
//  Achievement Card UI Component
//

import SwiftUI

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isUnlocked ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .tint(.green)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Text("+\(achievement.xpReward)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct AchievementBadgeView: View {
    let achievement: Achievement
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(achievement.isUnlocked ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: size, height: size)
            
            Image(systemName: achievement.iconName)
                .font(.system(size: size * 0.4))
                .foregroundColor(achievement.isUnlocked ? .green : .gray)
            
            if !achievement.isUnlocked {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: size, height: size)
            }
        }
    }
}

struct AchievementProgressHeader: View {
    let unlockedCount: Int
    let totalCount: Int
    let totalXP: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("\(totalXP) XP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                .tint(.green)
            
            Text("\(unlockedCount) of \(totalCount) unlocked")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AchievementUnlockAnimation: View {
    let achievement: Achievement
    @State private var showContent = false
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showContent ? 1 : 0)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text("Achievement Unlocked!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(achievement.title)
                    .font(.system(size: 24, weight: .bold))
                
                Text(achievement.description)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("+\(achievement.xpReward) XP")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.2), radius: 20)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showContent = true
            }
        }
    }
}
