//
//  ContentView.swift
//  suslife
//
//  Main Entry Point - Tab-based Navigation
//  Modified: Add shared service instances and inject via EnvironmentObject
//

import SwiftUI

struct ContentView: View {
    @StateObject private var achievementService = AchievementService()
    @StateObject private var rankingService = PersonalRankingService()
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(achievementService)
                .environmentObject(rankingService)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CommunityView()
                .environmentObject(achievementService)
                .environmentObject(rankingService)
                .tabItem {
                    Label("My Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    ContentView()
}
