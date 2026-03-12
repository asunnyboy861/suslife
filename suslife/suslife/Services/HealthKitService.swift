//
//  HealthKitService.swift
//  suslife
//
//  HealthKit Service - Handles Apple Health integration
//

import Foundation
import HealthKit

@MainActor
final class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var isHealthKitAvailable = false
    @Published var stepCount: Int = 0
    @Published var walkingDistance: Double = 0
    @Published var cyclingDistance: Double = 0
    @Published var flightsClimbed: Int = 0
    
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.workoutType()
    ]
    
    init() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async -> Bool {
        guard isHealthKitAvailable else { return false }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            UserDefaults.standard.set(true, forKey: "healthKitEnabled")
            return true
        } catch {
            print("HealthKit authorization error: \(error)")
            return false
        }
    }
    
    func fetchTodayStats() async {
        guard isAuthorized else { return }
        
        async let steps = fetchStepCount()
        async let walking = fetchWalkingDistance()
        async let cycling = fetchCyclingDistance()
        async let flights = fetchFlightsClimbed()
        
        stepCount = await steps
        walkingDistance = await walking
        cyclingDistance = await cycling
        flightsClimbed = await flights
    }
    
    func fetchStats(for date: Date) async -> HealthStats {
        guard isAuthorized else { return HealthStats() }
        
        async let steps = fetchStepCount(for: date)
        async let walking = fetchWalkingDistance(for: date)
        async let cycling = fetchCyclingDistance(for: date)
        async let flights = fetchFlightsClimbed(for: date)
        
        return await HealthStats(
            steps: steps,
            walkingDistance: walking,
            cyclingDistance: cycling,
            flightsClimbed: flights
        )
    }
    
    private func fetchStepCount(for date: Date? = nil) async -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        
        let targetDate = date ?? Date()
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? targetDate
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let count = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(count))
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchWalkingDistance(for date: Date? = nil) async -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return 0 }
        
        let targetDate = date ?? Date()
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? targetDate
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let distance = result?.sumQuantity()?.doubleValue(for: .mile()) ?? 0
                continuation.resume(returning: distance)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchCyclingDistance(for date: Date? = nil) async -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling) else { return 0 }
        
        let targetDate = date ?? Date()
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? targetDate
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let distance = result?.sumQuantity()?.doubleValue(for: .mile()) ?? 0
                continuation.resume(returning: distance)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchFlightsClimbed(for date: Date? = nil) async -> Int {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else { return 0 }
        
        let targetDate = date ?? Date()
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? targetDate
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: flightsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let count = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(count))
            }
            healthStore.execute(query)
        }
    }
    
    func calculateCO2FromWalking() -> Double {
        let carEmissionPerMile: Double = 0.13
        let co2Saved = walkingDistance * carEmissionPerMile
        return co2Saved
    }
    
    func calculateCO2FromCycling() -> Double {
        let carEmissionPerMile: Double = 0.13
        let co2Saved = cyclingDistance * carEmissionPerMile
        return co2Saved
    }
    
    func calculateCO2FromSteps() -> Double {
        let avgStepLengthMiles: Double = 0.000473
        let carEmissionPerMile: Double = 0.13
        let walkingDistanceMiles = Double(stepCount) * avgStepLengthMiles
        let co2Saved = walkingDistanceMiles * carEmissionPerMile
        return co2Saved
    }
    
    func calculateTotalCO2Saved() -> Double {
        return calculateCO2FromWalking() + calculateCO2FromCycling() + calculateCO2FromSteps()
    }
    
    func getHealthSummary() -> String {
        let totalCO2Saved = calculateTotalCO2Saved()
        return """
        Today's Health Stats:
        • Steps: \(stepCount) (≈ \(String(format: "%.1f", calculateCO2FromSteps())) lbs CO₂ saved)
        • Walking: \(String(format: "%.1f", walkingDistance)) mi (≈ \(String(format: "%.1f", calculateCO2FromWalking())) lbs CO₂ saved)
        • Cycling: \(String(format: "%.1f", cyclingDistance)) mi (≈ \(String(format: "%.1f", calculateCO2FromCycling())) lbs CO₂ saved)
        • Flights: \(flightsClimbed)
        
        Total CO₂ Saved: \(String(format: "%.1f", totalCO2Saved)) lbs
        """
    }
    
    func syncHealthDataToActivities() async throws {
        guard isAuthorized else { return }
        
        await fetchTodayStats()
        
        let repository = CoreDataActivityRepository()
        
        if walkingDistance > 0 {
            let input = ActivityInput(
                category: "transport",
                activityType: "walking",
                value: walkingDistance,
                unit: "mi",
                notes: "Auto-synced from Apple Health",
                date: Date()
            )
            _ = try await repository.save(input)
        }
        
        if cyclingDistance > 0 {
            let input = ActivityInput(
                category: "transport",
                activityType: "bicycle",
                value: cyclingDistance,
                unit: "mi",
                notes: "Auto-synced from Apple Health",
                date: Date()
            )
            _ = try await repository.save(input)
        }
    }
}

struct HealthStats {
    let steps: Int
    let walkingDistance: Double
    let cyclingDistance: Double
    let flightsClimbed: Int
    
    init(steps: Int = 0, walkingDistance: Double = 0, cyclingDistance: Double = 0, flightsClimbed: Int = 0) {
        self.steps = steps
        self.walkingDistance = walkingDistance
        self.cyclingDistance = cyclingDistance
        self.flightsClimbed = flightsClimbed
    }
    
    var totalCO2Saved: Double {
        let carEmissionPerMile: Double = 0.13
        let avgStepLengthMiles: Double = 0.000473
        
        let walkingCO2 = walkingDistance * carEmissionPerMile
        let cyclingCO2 = cyclingDistance * carEmissionPerMile
        let stepsCO2 = Double(steps) * avgStepLengthMiles * carEmissionPerMile
        
        return walkingCO2 + cyclingCO2 + stepsCO2
    }
}
