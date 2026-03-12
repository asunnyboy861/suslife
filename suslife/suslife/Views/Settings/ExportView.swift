//
//  ExportView.swift
//  suslife
//
//  Export View - Data export options UI
//

import SwiftUI

enum ExportFormat {
    case csv, json, pdf
}

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    private let exportService = ExportService()
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    @State private var shareText: String?
    @State private var showAuthError = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    Button(action: { exportData(format: .csv) }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(AppColors.primary)
                            VStack(alignment: .leading) {
                                Text("CSV")
                                    .foregroundColor(.primary)
                                Text("Compatible with Excel, Google Sheets")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isExporting)
                    
                    Button(action: { exportData(format: .json) }) {
                        HStack {
                            Image(systemName: "doc.badge.gearshape")
                                .foregroundColor(AppColors.primary)
                            VStack(alignment: .leading) {
                                Text("JSON")
                                    .foregroundColor(.primary)
                                Text("Machine-readable format")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isExporting)
                    
                    Button(action: { exportData(format: .pdf) }) {
                        HStack {
                            Image(systemName: "doc.richtext")
                                .foregroundColor(AppColors.primary)
                            VStack(alignment: .leading) {
                                Text("PDF Report")
                                    .foregroundColor(.primary)
                                Text("Beautiful summary report")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isExporting)
                }
                
                Section(header: Text("Share")) {
                    Button(action: shareProgress) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppColors.accent)
                            Text("Share My Progress")
                                .foregroundColor(.primary)
                        }
                    }
                    .disabled(isExporting)
                }
                
                if let error = exportError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if isExporting {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Exporting data...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Info")) {
                    Text("Export includes all your activity history with dates, categories, CO2 savings, and notes. Biometric authentication required for data export.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                } else if let text = shareText {
                    ShareSheet(items: [text])
                }
            }
            .alert("Authentication Required", isPresented: $showAuthError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please authenticate to export your data.")
            }
        }
    }
    
    private func exportData(format: ExportFormat) {
        isExporting = true
        exportError = nil
        
        Task {
            let authenticated = await exportService.authenticateWithBiometrics()
            
            guard authenticated else {
                await MainActor.run {
                    showAuthError = true
                    isExporting = false
                }
                return
            }
            
            do {
                let fileURL: URL
                switch format {
                case .csv:
                    fileURL = try await exportService.exportToCSV()
                case .json:
                    fileURL = try await exportService.exportToJSON()
                case .pdf:
                    fileURL = try await exportService.exportToPDF()
                }
                
                await MainActor.run {
                    shareURL = fileURL
                    shareText = nil
                    showingShareSheet = true
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    exportError = "Failed to export: \(error.localizedDescription)"
                    isExporting = false
                }
            }
        }
    }
    
    private func shareProgress() {
        isExporting = true
        exportError = nil
        
        Task {
            do {
                let text = try await exportService.generateShareText()
                await MainActor.run {
                    shareText = text
                    shareURL = nil
                    showingShareSheet = true
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    exportError = "Failed to generate share text: \(error.localizedDescription)"
                    isExporting = false
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
}
