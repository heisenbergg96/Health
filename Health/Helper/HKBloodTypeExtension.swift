//
//  HKBloodTypeExtension.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import HealthKit

extension HKBloodType {
    
    var stringRepresentation: String {
        switch self {
        case .notSet:
            return "Unknown"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        }
    }
}
