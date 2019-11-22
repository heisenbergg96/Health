//
//  HKGenderExtension.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import HealthKit

extension HKBiologicalSex {
    
    var stringRepresentation: String {
        switch self {
        case .notSet:
            return "Unknown"
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        }
    }
}
