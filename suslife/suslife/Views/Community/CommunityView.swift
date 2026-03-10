//
//  CommunityView.swift
//  suslife
//
//  Community View - Leaderboard and community features
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var rankingService = RankingService()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Leaderboard", selection: $selectedTab) {
                    Text("All Time").tag(0)
                    Text("This Week").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    AllTimeLeaderboardView(rankingService: rankingService)
                        .tag(0)
                    
                    WeeklyLeaderboardView(rankingService: rankingService)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Community")
            .task {
                await loadLeaderboard()
            }
        }
    }
    
    private func loadLeaderboard() async {
        _ = try? await rankingService.getLeaderboard()
    }
}

struct AllTimeLeaderboardView: View {
    @ObservedObject var rankingService: RankingService
    @State private var entries: [LeaderboardEntry] = []
    
    var body: some View {
        List {
            if let userEntry = entries.first(where: { $0.id == "current_user" }) {
                Section(header: Text("Your Ranking")) {
                    LeaderboardRow(entry: userEntry, isCurrentUser: true)
                }
            }
            
            Section(header: Text("Top Community Members")) {
                ForEach(entries.filter { $0.id != "current_user" }) { entry in
                    LeaderboardRow(entry: entry, isCurrentUser: false)
                }
            }
        }
        .task {
            entries = (try? await rankingService.getLeaderboard()) ?? []
        }
    }
}

struct WeeklyLeaderboardView: View {
    @ObservedObject var rankingService: RankingService
    @State private var entries: [LeaderboardEntry] = []
    
    var body: some View {
        List {
            if let userEntry = entries.first(where: { $0.id == "current_user" }) {
                Section(header: Text("Your Weekly Ranking")) {
                    LeaderboardRow(entry: userEntry, isCurrentUser: true)
                }
            }
            
            Section(header: Text("This Week's Top")) {
                ForEach(entries.filter { $0.id != "current_user" }) { entry in
                    LeaderboardRow(entry: entry, isCurrentUser: false)
                }
            }
        }
        .task {
            entries = (try? await rankingService.getWeeklyLeaderboard()) ?? []
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text("#\(entry.rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 30)
            
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: entry.avatarName)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.system(size: 16, weight: isCurrentUser ? .bold : .medium))
                
                HStack(spacing: 8) {
                    Label("\(entry.totalActivities)", systemImage: "checkmark.circle.fill")
                    Label("\(entry.currentStreak)d", systemImage: "flame.fill")
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(entry.formattedCO2)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.accent)
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch entry.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
    }
}

#Preview {
    CommunityView()
}
