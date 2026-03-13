//
//  ContentView.swift
//  suslife
//
//  Main Entry Point - Tab-based Navigation
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CommunityView()
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
