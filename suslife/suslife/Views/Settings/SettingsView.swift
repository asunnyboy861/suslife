//
//  SettingsView.swift
//  suslife
//
//  Settings View - App configuration
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("cloudKitSyncEnabled") private var cloudKitSyncEnabled = false
    @AppStorage("unitsSystem") private var unitsSystem = "imperial"
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("healthKitEnabled") private var healthKitEnabled = false
    
    @StateObject private var notificationService = NotificationService()
    @StateObject private var healthKitService = HealthKitService()
    @State private var showingReminderPicker = false
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                notificationSection
                
                healthKitSection
                
                dataSection
                
                privacySection
                
                unitsSection
                
                exportSection
                
                aboutSection
                
                legalSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
        }
    }
    
    private var notificationSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Daily Reminder", isOn: $dailyReminderEnabled)
                .onChange(of: dailyReminderEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationService.requestAuthorization()
                            if notificationService.isAuthorized {
                                await notificationService.scheduleDailyReminder(at: reminderHour, minute: reminderMinute)
                            }
                        }
                    } else {
                        notificationService.cancelDailyReminder()
                    }
                }
            
            if dailyReminderEnabled {
                Button(action: { showingReminderPicker = true }) {
                    HStack {
                        Text("Reminder Time")
                        Spacer()
                        Text(String(format: "%02d:%02d", reminderHour, reminderMinute))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingReminderPicker) {
                    ReminderTimePickerView(hour: $reminderHour, minute: $reminderMinute)
                }
            }
            
            if !notificationService.isAuthorized && notificationService.authorizationStatus == .notDetermined {
                Button("Request Notification Permission") {
                    Task {
                        _ = await notificationService.requestAuthorization()
                    }
                }
            }
            
            if notificationService.authorizationStatus == .denied {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private var healthKitSection: some View {
        Section(header: Text("Apple Health")) {
            Toggle("Connect Apple Health", isOn: $healthKitEnabled)
                .onChange(of: healthKitEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await healthKitService.requestAuthorization()
                        }
                    }
                }
            
            if healthKitService.isAuthorized {
                HStack {
                    Text("Status")
                    Spacer()
                    Text("Connected")
                        .foregroundColor(.green)
                }
                
                Button("Refresh Health Data") {
                    Task {
                        await healthKitService.fetchTodayStats()
                    }
                }
            } else if !healthKitService.isHealthKitAvailable {
                Text("Apple Health is not available on this device")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Connect to import your walking, cycling, and step data from Apple Health.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var dataSection: some View {
        Section(header: Text("Data")) {
            Button(action: { showingExportSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Data")
                }
            }
        }
    }
    
    private var privacySection: some View {
        Section(header: Text("Privacy & Data")) {
            Toggle("Enable iCloud Sync", isOn: $cloudKitSyncEnabled)
            
            Text("When enabled, your data syncs to your iCloud account for backup.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var unitsSection: some View {
        Section(header: Text("Units")) {
            Picker("Units System", selection: $unitsSystem) {
                Text("Imperial (mi, lbs)").tag("imperial")
                Text("Metric (km, kg)").tag("metric")
            }
        }
    }
    
    private var exportSection: some View {
        Section(header: Text("Export")) {
            Button(action: { showingExportSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Activity Data")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Emission Factors Version")
                Spacer()
                Text(EmissionFactorsVersion.current)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var legalSection: some View {
        Section(header: Text("Legal")) {
            Link("Privacy Policy", destination: URL(string: "https://yourwebsite.com/privacy")!)
            Link("Terms of Service", destination: URL(string: "https://yourwebsite.com/terms")!)
        }
    }
}

struct ReminderTimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            DatePicker(
                "Reminder Time",
                selection: Binding(
                    get: {
                        var components = DateComponents()
                        components.hour = hour
                        components.minute = minute
                        return Calendar.current.date(from: components) ?? Date()
                    },
                    set: { newDate in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                        hour = components.hour ?? 9
                        minute = components.minute ?? 0
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let notificationService = NotificationService()
                            await notificationService.scheduleDailyReminder(at: hour, minute: minute)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
