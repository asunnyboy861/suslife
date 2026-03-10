//
//  ExportView.swift
//  suslife
//
//  Export View - Data export options UI
//

import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    @State private var shareText: String?
    
    private let exportService = ExportService()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    Button(action: exportCSV) {
                        Label("Export as CSV", systemImage: "doc.text")
                    }
                    .disabled(isExporting)
                    
                    Button(action: exportJSON) {
                        Label("Export as JSON", systemImage: "doc")
                    }
                    .disabled(isExporting)
                }
                
                Section(header: Text("Share")) {
                    Button(action: shareProgress) {
                        Label("Share My Progress", systemImage: "square.and.arrow.up")
                    }
                }
                
                if let error = exportError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Info")) {
                    Text("Export includes all your activity history with dates, categories, CO2 savings, and notes.")
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
            .overlay {
                if isExporting {
                    ProgressView("Exporting...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func exportCSV() {
        isExporting = true
        exportError = nil
        
        Task {
            do {
                let url = try await exportService.exportToCSV()
                shareURL = url
                shareText = nil
                showingShareSheet = true
            } catch {
                exportError = "Failed to export: \(error.localizedDescription)"
            }
            isExporting = false
        }
    }
    
    private func exportJSON() {
        isExporting = true
        exportError = nil
        
        Task {
            do {
                let url = try await exportService.exportToJSON()
                shareURL = url
                shareText = nil
                showingShareSheet = true
            } catch {
                exportError = "Failed to export: \(error.localizedDescription)"
            }
            isExporting = false
        }
    }
    
    private func shareProgress() {
        isExporting = true
        exportError = nil
        
        Task {
            do {
                shareText = try await exportService.generateShareText()
                shareURL = nil
                showingShareSheet = true
            } catch {
                exportError = "Failed to generate share text: \(error.localizedDescription)"
            }
            isExporting = false
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
