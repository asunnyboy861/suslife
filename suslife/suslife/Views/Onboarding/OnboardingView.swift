//
//  OnboardingView.swift
//  suslife
//
//  Onboarding - New user introduction flow
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var dailyGoal: Double = 20.0
    @State private var notificationsEnabled = false
    @State private var healthKitEnabled = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.fill",
            title: "Welcome to Suslife",
            description: "Track your carbon footprint and make sustainable choices every day.",
            accentColor: AppColors.primary
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Track Your Impact",
            description: "Log your daily activities - transport, food, shopping, and energy use. See how your choices affect the planet.",
            accentColor: AppColors.accent
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Earn Achievements",
            description: "Stay motivated with achievements and streaks. Every sustainable choice counts!",
            accentColor: .orange
        ),
        OnboardingPage(
            icon: "gearshape.fill",
            title: "Set Your Goals",
            description: "Customize your daily CO₂ goal and get personalized recommendations.",
            accentColor: AppColors.primary
        )
    ]
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if currentPage < pages.count {
                    pageView(pages[currentPage])
                        .transition(.opacity)
                } else {
                    setupView()
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
    
    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(page.accentColor.opacity(0.25))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(page.accentColor)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(Fonts.title1)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(Fonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            pageIndicator
            bottomButtons
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? AppColors.primary : AppColors.divider)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentPage)
            }
        }
        .padding(.bottom, 20)
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 0 && currentPage < pages.count {
                Button(action: {
                    withAnimation {
                        currentPage -= 1
                    }
                }) {
                    Text("Back")
                        .font(Fonts.headline)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                }
            }
            
            Button(action: {
                withAnimation {
                    if currentPage < pages.count {
                        currentPage += 1
                    }
                }
            }) {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .font(Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    private func setupView() -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Quick Setup")
                .font(Fonts.title1)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Customize your experience")
                .font(Fonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: 20) {
                dailyGoalSection
                notificationsSection
                healthKitSection
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: completeOnboarding) {
                Text("Start Tracking")
                    .font(Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private var dailyGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(AppColors.primary)
                Text("Daily CO₂ Goal")
                    .font(Fonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(Int(dailyGoal)) lbs")
                    .font(Fonts.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }
            
            Slider(value: $dailyGoal, in: 5...50, step: 5)
                .tint(AppColors.primary)
            
            Text("Recommended: 20 lbs/day for a sustainable lifestyle")
                .font(Fonts.caption1)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var notificationsSection: some View {
        Toggle(isOn: $notificationsEnabled) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppColors.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminders")
                        .font(Fonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Get reminded to log activities")
                        .font(Fonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var healthKitSection: some View {
        Toggle(isOn: $healthKitEnabled) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Health")
                        .font(Fonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Auto-sync walking & cycling data")
                        .font(Fonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func completeOnboarding() {
        Task {
            if notificationsEnabled {
                let service = NotificationService.shared
                _ = await service.requestAuthorization()
                if service.isAuthorized {
                    await service.scheduleDailyReminder(at: 20, minute: 0)
                }
            }
            
            if healthKitEnabled {
                let healthService = HealthKitService()
                _ = await healthService.requestAuthorization()
            }
            
            await saveUserProfile()
            
            await MainActor.run {
                OnboardingState.shared.completeOnboarding(dailyGoal: dailyGoal)
                isPresented = false
            }
        }
    }
    
    private func saveUserProfile() async {
        let context = CoreDataStack.shared.mainContext
        await context.perform {
            let profile = UserProfile(context: context)
            profile.id = UUID()
            profile.joinDate = Date()
            profile.dailyCO2Goal = self.dailyGoal
            profile.weeklyStreak = 0
            profile.totalActivitiesLogged = 0
            profile.cloudKitSyncEnabled = false
            profile.unitsSystem = "imperial"
            
            try? context.save()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
