//
//  suslifeApp.swift
//  suslife
//
//  Created by MacMini4 on 2026/3/10.
//

import SwiftUI

@main
struct suslifeApp: App {
    @StateObject private var onboardingState = OnboardingState.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
                
                if !onboardingState.isCompleted {
                    OnboardingView(onComplete: {
                        withAnimation {
                            onboardingState.isCompleted = true
                        }
                    })
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .animation(.easeInOut, value: onboardingState.isCompleted)
        }
    }
}
