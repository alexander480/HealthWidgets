//
//  SleepDataModel.swift
//  HealthWidgets
//
//  Created by Alexander Lester on 2/15/21.
//

import Foundation
import SwiftUI

import HealthKit

struct SleepData {
    let timeInBed: TimeInterval
    let timeAsleep: TimeInterval
}

class SleepModel: ObservableObject {
    @Published var sleepData: SleepData = SleepData(timeInBed: .zero, timeAsleep: .zero)
    
    init() {
        self.update()
    }
    
    func update() {
        SleepHelper.requestAuthorization { (isAuthorized, error) in
            if (isAuthorized) {
                SleepHelper.fetchData { (newSleepData) in
                    guard let newSleepData = newSleepData else { print("[ERROR] Failed To Validate SleepData From SleepHelper.fetchData."); return }
                    DispatchQueue.main.async { self.sleepData = newSleepData }
                }
            }
            else {
                print("[ERROR] Failed To Authorize HealthKit Access. [MESSAGE] \(String(describing: error))")
            }
        }
    }
}

//else {
//                if let error = error { print("[ERROR] Failed To Authorize HealthKit Access. [MESSAGE] \(error)") }
//                else { print("[ERROR] Failed To Authorize HealthKit Access. [MESSAGE] Failed To Validate HKCategoryType.") }
//
//                completion(nil)
//                return
//            }
