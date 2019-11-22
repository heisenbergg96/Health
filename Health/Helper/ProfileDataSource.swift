//
//  ProfileDataSource.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import HealthKit

class ProfileDataStore {
    
    class func getAgeSexAndBloodType() throws -> (age: Int, biologicalSex: HKBiologicalSex, bloodType: HKBloodType) {
            
            let healthKitStore = HKHealthStore()
            
            do {
                let birthdayComponents = try healthKitStore.dateOfBirthComponents()
                let biologicalSex = try healthKitStore.biologicalSex()
                let bloodType = try healthKitStore.bloodType()
                
                let today = Date()
                let calendar = Calendar.current
                let todayDateComponents = calendar.dateComponents([.year], from: today)
                let thisYear = todayDateComponents.year!
                let age = thisYear - birthdayComponents.year!
                let unwrappedBiologicalSex = biologicalSex.biologicalSex
                let unwrappedBloodType = bloodType.bloodType
                
                return (age, unwrappedBiologicalSex, unwrappedBloodType)
            }
    }
    
    class func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { _, samples, error in
                                            
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                completion(mostRecentSample, nil)
                                            }
        }
        HKHealthStore().execute(sampleQuery)
    }
    
    class func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
        
        guard let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
            fatalError("Body Mass Index Type is no longer available in HealthKit")
        }
        
        let bodyMassQuantity = HKQuantity(unit: HKUnit.count(),
                                          doubleValue: bodyMassIndex)
        
        let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType,
                                                   quantity: bodyMassQuantity,
                                                   start: date,
                                                   end: date)
        
        HKHealthStore().save(bodyMassIndexSample) { _, error in
            
            if let error = error {
                print("Error Saving BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully saved BMI Sample")
            }
        }
    }
    
    class func saveStepCountSample(steps: Int, date: Date) {
        
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            fatalError("Body Mass Index Type is no longer available in HealthKit")
        }
        
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: Double(steps))
        
        let stepCountSample = HKQuantitySample(type: stepCount,
                                               quantity: stepQuantity,
                                               start: date,
                                               end: date)
        
        HKHealthStore().save(stepCountSample) { _, error in
            
            if let error = error {
                print("Error Saving steps: \(error.localizedDescription)")
            } else {
                print("Successfully saved stepcount")
            }
        }
    }
}
