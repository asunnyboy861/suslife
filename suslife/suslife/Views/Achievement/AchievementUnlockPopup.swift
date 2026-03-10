//
//  AchievementUnlockPopup.swift
//  suslife
//
//  Achievement Unlock Animation Popup
//

import SwiftUI

struct AchievementUnlockPopup: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var iconScale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissPopup()
                }
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(iconScale)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                        .scaleEffect(iconScale)
                }
                
                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(achievement.title)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(achievement.description)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("+\(achievement.xpReward) XP")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.orange)
                }
                
                Button(action: dismissPopup) {
                    Text("Awesome!")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(AppColors.cardBackground)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2)) {
                iconScale = 1
            }
        }
    }
    
    private func dismissPopup() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

#Preview {
    AchievementUnlockPopup(
        achievement: Achievement(
            id: "first_log",
            title: "First Step",
            description: "Log your first sustainable activity",
            iconName: "leaf.fill",
            category: .logging,
            requirement: .totalActivities(count: 1),
            xpReward: 10
        ),
        isPresented: .constant(true)
    )
}
