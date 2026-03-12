//
//  ActivityEvents.swift
//  suslife
//
//  Activity Events - Notification center for activity-related events
//

import Foundation

extension Notification.Name {
    static let activityDidSave = Notification.Name("activityDidSave")
    static let achievementDidUnlock = Notification.Name("achievementDidUnlock")
}

struct ActivityEvent {
    static func notifyActivitySaved(co2Amount: Double, category: String) {
        NotificationCenter.default.post(
            name: .activityDidSave,
            object: nil,
            userInfo: [
                "co2Amount": co2Amount,
                "category": category,
                "timestamp": Date()
            ]
        )
    }
    
    static func observeActivitySaved(_ handler: @escaping (Double, String) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(
            forName: .activityDidSave,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let co2Amount = userInfo["co2Amount"] as? Double,
                  let category = userInfo["category"] as? String else {
                return
            }
            handler(co2Amount, category)
        }
    }
}
