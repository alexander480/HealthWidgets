//
//  SleepHelper.swift
//  HealthWidgets
//
//  Created by Alexander Lester on 2/15/21.
//

import Foundation
import SwiftUI

import HealthKit

struct SleepHelper {
    
    static let healthStore = HKHealthStore()
    
    // -- For Widget
    static func checkRequestStatusForAuthorization(completion: @escaping (Bool, HKAuthorizationRequestStatus?) -> ()) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            print("[ERROR] Failed To Validate HKCategoryType.")
            completion(false, nil)
            return
        }
        
        SleepHelper.healthStore.getRequestStatusForAuthorization(toShare: Set(), read: Set([sleepType])) { (status, error) in
            switch status {
                case .shouldRequest:
                    completion(false, status)
                case .unnecessary:
                    completion(true, status)
                case .unknown:
                    completion(false, status)
                @unknown default:
                    completion(false, status)
            }
        }
    }
    
    // -- Used In SleepHelper.requestAuthorization
    static func checkAuthorization(type: HKCategoryType, completion: @escaping (Bool) -> ()) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            print("[ERROR] Failed To Validate HKCategoryType.")
            completion(false)
            return
        }
        
        switch SleepHelper.healthStore.authorizationStatus(for: sleepType) {
            case .notDetermined:
                print("[WARNING] Authorization Status: Not Determined.")
                completion(false)
            case .sharingAuthorized:
                print("[INFO] Already Authorized.")
                completion(true)
            case .sharingDenied:
                print("[WARNING] Authorization Status: Sharing Denied.")
                completion(false)
            @unknown default:
                print("[WARNING] Unknown Authorization Status.")
                completion(false)
        }
    }
    
    static func requestAuthorization(completion: @escaping (Bool, Error?) -> ()) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            print("[ERROR] Failed To Validate HKCategoryType.")
            completion(false, nil)
            return
        }
        
        SleepHelper.checkAuthorization(type: sleepType) { (isAuthorized) in
            if (isAuthorized) {
                completion(true, nil)
            }
            else {
                SleepHelper.healthStore.requestAuthorization(toShare: nil, read: Set([sleepType])) { (success, error) -> Void in
                    if (success) { print("[SUCCESS] Successfully Authorized HealthKit."); completion(true, nil) }
                    else { print("[ERROR] Failed To Authorize HealthKit."); completion(false, error) }
                }
            }
        }
    }
    
    
    
    static func fetchData(completion: @escaping (SleepData?) -> ()) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            print("[ERROR] Failed To Validate HKCategoryType.")
            completion(nil)
            return
        }

        // HKSampleQuery Parameters
        
         let startDate = Date().addingTimeInterval(-86400)
         let endDate = Date()
         let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        // let startDate = Date(timeIntervalSince1970: 1613192400) // Feb 13, 2021 // 12:00 AM //
        // let endDate = Date(timeIntervalSince1970: 1613278800) // Feb 14, 2021 // 12:00 AM //
        // let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let sort = [ NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true) ]
        let limit = Int(HKObjectQueryNoLimit)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: limit, sortDescriptors: sort) { (query, samples, error) in
            // Validate Samples
            if let samples = samples as? [HKCategorySample] {

                // Seperate Samples By Type
                let inBedSamples: [HKCategorySample] = samples.filter { return $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
                let asleepSamples: [HKCategorySample] = samples.filter { return $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
                
                // Calculate Duration For Each Sample
                let inBedDurations: [TimeInterval] = inBedSamples.map { return $0.startDate.distance(to: $0.endDate) }
                let asleepDurations: [TimeInterval] = asleepSamples.map { return $0.startDate.distance(to: $0.endDate) }

                // Get Durations
                let timeInBed = inBedDurations.reduce(0, +)
                let timeAsleep = asleepDurations.reduce(0, +)
                
                // Print Data
                print("[INFO] Time In Bed: \(timeInBed / 60) Minutes.")
                print("[INFO] Time Asleep: \(timeAsleep / 60) Minutes.")
                
                // Return SleepData Object
                completion(SleepData(timeInBed: timeInBed, timeAsleep: timeAsleep))
            }
            
            // Handle Sample Validation Error
            else {
                if let error = error { print("[ERROR] Failed To Validate Samples. [MESSAGE] \(error.localizedDescription)") }
                else { print("[ERROR] Failed To Validate Samples.") }
                
                completion(nil)
                return
            }
        }
        
        SleepHelper.healthStore.execute(query)
    }
}

