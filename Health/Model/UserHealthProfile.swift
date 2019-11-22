//
//  UserHealthProfile.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import HealthKit

class UserHealthProfile {
    
    var age: Int?
    var biologicalSex: HKBiologicalSex?
    var bloodType: HKBloodType?
    var heightInMeters: Double?
    var weightInKilograms: Double?
    
    var bodyMassIndex: Double? {
        
        guard let weightInKilograms = weightInKilograms,
            let heightInMeters = heightInMeters,
            heightInMeters > 0 else {
                return nil
        }
        
        return (weightInKilograms / (heightInMeters * heightInMeters))
    }
}
