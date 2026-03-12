//
//  RegionSettingsView.swift
//  suslife
//
//  Region Settings - Allows users to select their region and unit system
//

import SwiftUI

struct RegionSettingsView: View {
    @StateObject private var regionManager = RegionManager.shared
    @State private var showingRegionPicker = false
    @State private var showingUnitPicker = false
    
    var body: some View {
        List {
            Section(header: Text("Region & Units")) {
                HStack {
                    Text("Region")
                    Spacer()
                    Button(action: { showingRegionPicker = true }) {
                        HStack(spacing: 8) {
                            Text(regionManager.currentRegion.flagEmoji)
                            Text(regionManager.currentRegion.displayName)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack {
                    Text("Unit System")
                    Spacer()
                    Button(action: { showingUnitPicker = true }) {
                        HStack(spacing: 8) {
                            Text(regionManager.unitSystem == .imperial ? "Imperial (mi, lbs)" : "Metric (km, kg)")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(header: Text("Emission Factors")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Data Source")
                        Spacer()
                        Text(regionManager.emissionFactors.source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Last Updated")
                        Spacer()
                        Text(regionManager.emissionFactors.lastUpdated)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink("View Emission Factors") {
                    EmissionFactorsDetailView(region: regionManager.currentRegion)
                }
            }
            
            Section(footer: Text("Your region determines the emission factors used for CO₂ calculations. Select your actual location for the most accurate results.")) {
                EmptyView()
            }
        }
        .navigationTitle("Region Settings")
        .sheet(isPresented: $showingRegionPicker) {
            RegionPickerView(selectedRegion: $regionManager.currentRegion)
        }
        .sheet(isPresented: $showingUnitPicker) {
            UnitSystemPickerView(selectedSystem: $regionManager.unitSystem)
        }
    }
}

struct RegionPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRegion: Region
    
    private let regions = Region.allCases
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Americas")) {
                    ForEach(regions.filter { $0 == .unitedStates }, id: \.self) { region in
                        RegionRow(region: region, isSelected: selectedRegion == region) {
                            selectedRegion = region
                            dismiss()
                        }
                    }
                }
                
                Section(header: Text("Nordic Countries")) {
                    ForEach(regions.filter { [.sweden, .norway, .denmark, .finland].contains($0) }, id: \.self) { region in
                        RegionRow(region: region, isSelected: selectedRegion == region) {
                            selectedRegion = region
                            dismiss()
                        }
                    }
                }
                
                Section(header: Text("Western Europe")) {
                    ForEach(regions.filter { [.germany, .france, .unitedKingdom, .netherlands].contains($0) }, id: \.self) { region in
                        RegionRow(region: region, isSelected: selectedRegion == region) {
                            selectedRegion = region
                            dismiss()
                        }
                    }
                }
                
                Section(header: Text("Southern Europe")) {
                    ForEach(regions.filter { [.spain, .italy].contains($0) }, id: \.self) { region in
                        RegionRow(region: region, isSelected: selectedRegion == region) {
                            selectedRegion = region
                            dismiss()
                        }
                    }
                }
                
                Section(header: Text("Eastern Europe")) {
                    ForEach(regions.filter { $0 == .poland }, id: \.self) { region in
                        RegionRow(region: region, isSelected: selectedRegion == region) {
                            selectedRegion = region
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Region")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RegionRow: View {
    let region: Region
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(region.flagEmoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(region.displayName)
                        .foregroundColor(.primary)
                    
                    Text(region.unitSystem == .imperial ? "Imperial units" : "Metric units")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

struct UnitSystemPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedSystem: UnitSystem
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    selectedSystem = .imperial
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Imperial")
                                .foregroundColor(.primary)
                            Text("Miles, Pounds (lbs)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedSystem == .imperial {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                
                Button(action: {
                    selectedSystem = .metric
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Metric")
                                .foregroundColor(.primary)
                            Text("Kilometers, Kilograms (kg)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedSystem == .metric {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .navigationTitle("Unit System")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmissionFactorsDetailView: View {
    let region: Region
    
    var body: some View {
        List {
            Section(header: Text("Transport (CO₂ per distance)")) {
                let factors = region.emissionFactors.transport
                let unit = region.unitSystem == .imperial ? "mile" : "km"
                
                EmissionFactorRow(name: "Walking", value: factors.walking, unit: unit)
                EmissionFactorRow(name: "Bicycle", value: factors.bicycle, unit: unit)
                EmissionFactorRow(name: "Bus", value: factors.bus, unit: unit)
                EmissionFactorRow(name: "Train", value: factors.train, unit: unit)
                EmissionFactorRow(name: "Car (Gas)", value: factors.car, unit: unit)
                EmissionFactorRow(name: "Electric Vehicle", value: factors.ev, unit: unit)
                EmissionFactorRow(name: "Flight", value: factors.flight, unit: unit)
            }
            
            Section(header: Text("Food (CO₂ per portion)")) {
                let factors = region.emissionFactors.food
                
                EmissionFactorRow(name: "Vegan Meal", value: factors.vegan, unit: "portion")
                EmissionFactorRow(name: "Vegetarian Meal", value: factors.vegetarian, unit: "portion")
                EmissionFactorRow(name: "Chicken", value: factors.chicken, unit: "portion")
                EmissionFactorRow(name: "Pork", value: factors.pork, unit: "portion")
                EmissionFactorRow(name: "Beef", value: factors.beef, unit: "portion")
                EmissionFactorRow(name: "Fish", value: factors.fish, unit: "portion")
                EmissionFactorRow(name: "Dairy", value: factors.dairy, unit: "portion")
            }
            
            Section(header: Text("Shopping (CO₂ per item)")) {
                let factors = region.emissionFactors.shopping
                
                EmissionFactorRow(name: "Clothing", value: factors.clothing, unit: "item")
                EmissionFactorRow(name: "Electronics", value: factors.electronics, unit: "item")
                EmissionFactorRow(name: "Furniture", value: factors.furniture, unit: "item")
                EmissionFactorRow(name: "Books", value: factors.books, unit: "item")
                EmissionFactorRow(name: "Household", value: factors.household, unit: "item")
            }
            
            Section(header: Text("Energy (CO₂ per kWh)")) {
                let factors = region.emissionFactors.energy
                
                EmissionFactorRow(name: "Electricity (Grid)", value: factors.electricity, unit: "kWh")
                EmissionFactorRow(name: "Natural Gas", value: factors.naturalGas, unit: "kWh")
                EmissionFactorRow(name: "Propane", value: factors.propane, unit: "kWh")
                EmissionFactorRow(name: "Solar", value: factors.solar, unit: "kWh")
                EmissionFactorRow(name: "Wind", value: factors.wind, unit: "kWh")
            }
            
            Section(header: Text("Data Source")) {
                Text(region.emissionFactors.source)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("Last Updated: \(region.emissionFactors.lastUpdated)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(region.displayName)
    }
}

struct EmissionFactorRow: View {
    let name: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if value == 0 {
                Text("Zero emission")
                    .foregroundColor(.green)
                    .font(.subheadline)
            } else {
                let weightUnit = RegionManager.shared.unitSystem == .imperial ? "lbs" : "kg"
                Text(String(format: "%.3f %@ CO₂/%@", value, weightUnit, unit))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    NavigationView {
        RegionSettingsView()
    }
}
