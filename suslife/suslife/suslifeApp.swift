//
//  suslifeApp.swift
//  suslife
//
//  Created by MacMini4 on 2026/3/10.
//

import SwiftUI

@main
struct suslifeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
        }
    }
}
