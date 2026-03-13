//
//  SettingsView.swift
//  suslife
//
//  Settings View - App configuration
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("unitsSystem") private var unitsSystem = "imperial"
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("healthKitEnabled") private var healthKitEnabled = false
    
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var healthKitService = HealthKitService()
    @StateObject private var cloudKitService = CloudKitSyncService.shared
    @State private var showingReminderPicker = false
    @State private var showingExportSheet = false
    @State private var showingContactSupport = false
    
    var body: some View {
        NavigationView {
            Form {
                regionSection
                
                notificationSection
                
                healthKitSection
                
                cloudKitSection
                
                dataSection
                
                aboutSection
                
                legalSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showingContactSupport) {
                ContactSupportView()
            }
            .task {
                await cloudKitService.checkAccountStatus()
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
    
    private var cloudKitSection: some View {
        Section(header: Text("iCloud Sync")) {
            Toggle("Enable iCloud Sync", isOn: Binding(
                get: { cloudKitService.isSyncEnabled },
                set: { newValue in
                    Task {
                        if newValue {
                            _ = await cloudKitService.enableSync()
                        } else {
                            cloudKitService.disableSync()
                        }
                    }
                }
            ))
            
            HStack {
                Text("Status")
                Spacer()
                Text(cloudKitService.getSyncStatusDescription())
                    .foregroundColor(cloudKitService.syncStatus == .synced ? .green : .secondary)
                    .font(.caption)
            }
            
            if cloudKitService.isSyncEnabled {
                Button("Sync Now") {
                    Task {
                        await cloudKitService.syncNow()
                    }
                }
                .disabled(cloudKitService.syncStatus == .syncing)
            }
            
            Text("When enabled, your activity data syncs to iCloud for backup and sharing across devices.")
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
    
    private var regionSection: some View {
        Section(header: Text("Region & Units")) {
            NavigationLink(destination: RegionSettingsView()) {
                HStack {
                    Text(RegionManager.shared.currentRegion.flagEmoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Region")
                            .foregroundColor(.primary)
                        Text("\(RegionManager.shared.currentRegion.displayName) • \(RegionManager.shared.unitSystem == .imperial ? "Imperial" : "Metric")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
                Text("Emission Factors")
                Spacer()
                Text(RegionManager.shared.currentRegion.emissionFactors.source)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Button(action: { showingContactSupport = true }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(AppColors.primary)
                    Text("Contact Support")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
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
            Form {
                Section {
                    HStack(spacing: 0) {
                        // Hour picker
                        Picker("Hour", selection: $hour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour))
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        
                        Text(":")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        
                        // Minute picker
                        Picker("Minute", selection: $minute) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 200)
                }
            }
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
