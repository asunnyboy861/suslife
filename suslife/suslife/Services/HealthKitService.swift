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
    
    private func fetchStepCount() async -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
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
    
    private func fetchWalkingDistance() async -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return 0 }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let distanceInMiles = await withCheckedContinuation { continuation in
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
        
        return distanceInMiles
    }
    
    private func fetchCyclingDistance() async -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling) else { return 0 }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
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
    
    private func fetchFlightsClimbed() async -> Int {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else { return 0 }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
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
        let co2PerMile: Double = 0.0
        return walkingDistance * co2PerMile
    }
    
    func calculateCO2FromCycling() -> Double {
        let co2PerMile: Double = 0.0
        return cyclingDistance * co2PerMile
    }
    
    func calculateCO2FromSteps() -> Double {
        let co2PerStep: Double = 0.0
        return Double(stepCount) * co2PerStep
    }
    
    func getHealthSummary() -> String {
        """
        Today's Health Stats:
        • Steps: \(stepCount)
        • Walking: \(String(format: "%.1f", walkingDistance)) mi
        • Cycling: \(String(format: "%.1f", cyclingDistance)) mi
        • Flights: \(flightsClimbed)
        """
    }
}
